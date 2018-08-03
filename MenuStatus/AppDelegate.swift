//
//  AppDelegate.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa
import OAuthSwift

struct KeychainConfiguration {
    static let serviceName = "MenuStatus"
    static let accessGroup: String? = nil
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar = NSStatusBar.system
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var status1MenuItem : NSMenuItem = NSMenuItem()
    var connectMenuItem : NSMenuItem = NSMenuItem()
    var quitMenuItem : NSMenuItem = NSMenuItem()
    
    var timer = Timer()
    var signedIn = false
    
    var profile: Profile?
    
    let slackService = SlackService()

    var oauthswift: OAuth2Swift?

    var passwordItem: KeychainPasswordItem?
    var token: String?
    
    override func awakeFromNib() {
        menu.autoenablesItems = false

        // add statusBarItem
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        statusBarItem.image = NSImage(named:NSImage.Name("Slack_Mark_Black_Web"))

        status1MenuItem.title = "Working remotely"
        status1MenuItem.target = self
        status1MenuItem.action = #selector(status1ItemAction)
        status1MenuItem.keyEquivalent = ""
        status1MenuItem.isEnabled = false
        menu.addItem(status1MenuItem)
        
        // add menuItem to menu
        connectMenuItem.title = "Sign in"
        connectMenuItem.target = self
        connectMenuItem.action = #selector(signInOut)
        connectMenuItem.keyEquivalent = ""
        connectMenuItem.isEnabled = true
        menu.addItem(connectMenuItem)
        
        // add menuItem to menu
        quitMenuItem.title = "Quit"
        quitMenuItem.target = self
        quitMenuItem.action = #selector(quit)
        quitMenuItem.keyEquivalent = ""
        quitMenuItem.isEnabled = true
        menu.addItem(quitMenuItem)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(AppDelegate.handleGetURL(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func status1ItemAction(sender: AnyObject) {
        NSLog("status1ItemAction called")
        slackService.setProfile(statusText: "Working remotely", statusEmoji: ":house_with_garden:") { result, errorMessage in
            if let result = result {
                self.profile = result
                self.statusBarItem.title = self.profile!.statusText
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
                self.status1MenuItem.isEnabled = true
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
                        self.saveTokenToKeychain(token: credential.oauthToken)
                        self.slackService.setToken(token: credential.oauthToken)
                        self.signedIn = true
                        self.getProfile(sender: self)
                        self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.getProfile), userInfo: nil, repeats: true)
                        self.connectMenuItem.title = "Sign out"
                        self.status1MenuItem.isEnabled = true
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
            self.statusBarItem.title = nil
            self.status1MenuItem.isEnabled = false
        }

    }
    
    @objc func getProfile(sender: AnyObject) {
        NSLog("getProfile called")
        slackService.getProfile() { result, errorMessage in
            if let result = result {
                self.profile = result
                self.statusBarItem.title = self.profile!.statusText
            }
        }
    }
    
    @objc func quit(sender: AnyObject) {
        NSApp.terminate(self);
    }

    @objc func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString) {
            OAuthSwift.handle(url: url)
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
}

