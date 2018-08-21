//
//  StatusItemController.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/20/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa
import OAuthSwift

let profileStatuses = [
    Profile(statusText: "Working remotely", statusEmoji: ":house_with_garden:"),
    Profile(statusText: "I'm working at the office", statusEmoji: ":office:")
]

class StatusItemController {
    var statusBar = NSStatusBar.system
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var statusMenuItems = [StatusMenuItem]()
    var connectMenuItem : NSMenuItem = NSMenuItem()
    var quitMenuItem : NSMenuItem = NSMenuItem()

    var timer = Timer()
    var signedIn = false

    var profile: Profile?

    let slackService = SlackService()

    var oauthswift: OAuth2Swift?

    var passwordItem: KeychainPasswordItem?
    var token: String?

    func setStatusBarIcon(string: String? = nil) {
        if (string != nil) {
            self.statusBarItem.title = string
            self.statusBarItem.image = nil
        } else {
            self.statusBarItem.image = NSImage(named:NSImage.Name("Slack_Mark_Black_Web"))
            self.statusBarItem.title = nil
        }
    }
    
    init() {
        menu.autoenablesItems = false

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        setStatusBarIcon()

        for profile in profileStatuses {
            let statusMenuItem = StatusMenuItem(profile: profile, statusItemController: self)
            menu.addItem(statusMenuItem.menuItem)
            statusMenuItems.append(statusMenuItem)
        }

        connectMenuItem.title = "Sign in"
        connectMenuItem.target = self
        connectMenuItem.action = #selector(signInOut)
        connectMenuItem.keyEquivalent = ""
        connectMenuItem.isEnabled = true
        menu.addItem(connectMenuItem)

        quitMenuItem.title = "Quit"
        quitMenuItem.target = self
        quitMenuItem.action = #selector(quit)
        quitMenuItem.keyEquivalent = ""
        quitMenuItem.isEnabled = true
        menu.addItem(quitMenuItem)
    }

    func enableStatusMenuItems() {
        for item in statusMenuItems {
            item.enable()
        }
    }

    func disableStatusMenuItems() {
        for item in statusMenuItems {
            item.disable()
        }
    }

    @objc func statusItemAction(sender: AnyObject) {
        NSLog("statusItemAction called")
        let newProfile = sender.representedObject as? Profile
        slackService.setProfile(statusText: newProfile!.statusText, statusEmoji: newProfile!.statusEmoji) { result, errorMessage in
            if let result = result {
                self.profile = result
                self.setStatusBarIcon(string: self.profile!.emojiCode())
            }
        }
    }

    @objc func signInOut(sender: AnyObject) {
        if !signedIn {
            let token = getTokenFromKeychain()
            if token != nil {
                slackService.setToken(token: token!)
                self.signedIn = true
                self.getProfile(sender: self)
                timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(getProfile), userInfo: nil, repeats: true)
                self.connectMenuItem.title = "Sign out"
                self.enableStatusMenuItems()
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
                        self.slackService.setToken(token: credential.oauthToken)
                        self.signedIn = true
                        self.getProfile(sender: self)
                        self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.getProfile), userInfo: nil, repeats: true)
                        self.connectMenuItem.title = "Sign out"
                        self.enableStatusMenuItems()
                },
                    failure: { (error: Error) in
                        NSLog(error.localizedDescription)
                }
                )
            }
        } else {
            timer.invalidate()
            self.signedIn = false
            self.connectMenuItem.title = "Sign in"
            setStatusBarIcon()
            self.disableStatusMenuItems()
        }
    }

    @objc func getProfile(sender: AnyObject) {
        NSLog("getProfile called")
        slackService.getProfile() { result, errorMessage in
            if let result = result {
                self.profile = result
                self.setStatusBarIcon(string: self.profile!.emojiCode())
            }
        }
    }

    @objc func quit(sender: AnyObject) {
        NSApp.terminate(self);
    }
}

func getTokenFromKeychain() -> String? {
    do {
        let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                             account: "slack-menu-status-token",
                                             accessGroup: KeychainConfiguration.accessGroup)
        let token = try tokenItem.readPassword()
        return token;
    } catch {
        return nil;
    }
}

func saveTokenToKeychain(token: String) {
    do {
        let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                             account: "slack-menu-status-token",
                                             accessGroup: KeychainConfiguration.accessGroup)
        try tokenItem.savePassword(token)
    } catch {
        return;
    }
}
