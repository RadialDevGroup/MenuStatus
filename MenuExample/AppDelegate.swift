//
//  AppDelegate.swift
//  MenuExample
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar = NSStatusBar.system
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var connectMenuItem : NSMenuItem = NSMenuItem()
    var quitMenuItem : NSMenuItem = NSMenuItem()
    
    var timer = Timer()
    var signedIn = false
    
    var profile: Profile?
    
    let slackService = SlackService()
    
    override func awakeFromNib() {
        // add statusBarItem
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        statusBarItem.title = "Slack Status: Sign in"
        
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
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func signInOut(sender: AnyObject) {
        if !signedIn {
            self.signedIn = true
            self.getProfile(sender: self)
            timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(getProfile), userInfo: nil, repeats: true)
            self.connectMenuItem.title = "Sign out"
        } else {
            timer.invalidate()
            self.signedIn = false
            self.connectMenuItem.title = "Sign in"
            self.statusBarItem.title = "Slack Status: Sign in"
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
}

