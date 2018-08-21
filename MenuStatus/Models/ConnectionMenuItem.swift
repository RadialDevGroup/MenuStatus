//
//  ConnectionMenuItem.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/21/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa
import OAuthSwift

class ConnectionMenuItem {
    var timer = Timer()
    var signedIn = false

    var oauthswift: OAuth2Swift?

    var menuItem: NSMenuItem
    var statusItemController: StatusItemController

    init(statusItemController: StatusItemController) {
        self.statusItemController = statusItemController
        menuItem = NSMenuItem()
        menuItem.title = "Sign In"
        menuItem.target = self
        menuItem.action = #selector(connectionAction)
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = true
    }

    @objc func connectionAction(sender: AnyObject) {
        if !signedIn {
            let token = getTokenFromKeychain()
            if token != nil {
                SlackService.shared.setToken(token: token!)
                self.signedIn = true
                self.getProfile(sender: self)
                timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(getProfile), userInfo: nil, repeats: true)
                self.menuItem.title = "Sign out"
                self.statusItemController.enableStatusMenuItems()
            } else {
                let oauthswift = OAuth2Swift(
                    consumerKey:    slackAppCreds.client_key,
                    consumerSecret: slackAppCreds.client_secret,
                    authorizeUrl:   "https://slack.com/oauth/authorize",
                    accessTokenUrl: "https://slack.com/api/oauth.access",
                    responseType:   "code"
                )
                self.oauthswift = oauthswift

                let state = generateState(withLength: 20)
                oauthswift.authorize(
                    withCallbackURL: URL(string: "menu-status://oauth-callback/slack")!, scope: "users.profile:read,users.profile:write", state: state,
                    success: { (credential, response, parameters) in
                        saveTokenToKeychain(token: credential.oauthToken)
                        SlackService.shared.setToken(token: credential.oauthToken)
                        self.signedIn = true
                        self.getProfile(sender: self)
                        self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.getProfile), userInfo: nil, repeats: true)
                        self.menuItem.title = "Sign out"
                        self.statusItemController.enableStatusMenuItems()
                },
                    failure: { (error: Error) in
                        NSLog(error.localizedDescription)
                }
                )
            }
        } else {
            timer.invalidate()
            self.signedIn = false
            self.menuItem.title = "Sign in"
            self.statusItemController.statusBarIcon = nil
            self.statusItemController.disableStatusMenuItems()
        }
    }

    @objc func getProfile(sender: AnyObject) {
        NSLog("getProfile called")
        SlackService.shared.getProfile() { result, errorMessage in
            if let result = result {
                self.statusItemController.profile = result
            }
        }
    }
}
