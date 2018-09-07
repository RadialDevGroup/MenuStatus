//
//  StatusItemController.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/20/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa

let slackImage = NSImage(named:NSImage.Name("Slack_Mark_Black_Web"))

class StatusItemController {
    var statusBar = NSStatusBar.system
    var statusBarItem: NSStatusItem = NSStatusItem()
    var statusBarIcon: String? {
        didSet {
            self.statusBarItem.image = self.statusBarIcon == nil ? slackImage : nil
            self.statusBarItem.title = self.statusBarIcon
        }
    }
    var menu: NSMenu = NSMenu()
    var statusMenuItems = [StatusMenuItem]()
    var statusMenuItemsEnabled = false
    var connectMenuItem: ConnectionMenuItem! = nil
    var preferencesMenuItem: PreferencesMenuItem! = nil
    var quitMenuItem: NSMenuItem = NSMenuItem()

    var profile: Profile? {
        didSet {
            self.statusBarIcon = String(self.profile!.emojiCode)
        }
    }

    var passwordItem: KeychainPasswordItem?
    var token: String?
    
    init() {
        menu.autoenablesItems = false

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        statusBarItem.image = slackImage

        let defaults = UserDefaults.standard
        if let savedProfileStatuses = defaults.object(forKey: "profileStatuses") as? Data {
            profileStatuses = NSKeyedUnarchiver.unarchiveObject(with: savedProfileStatuses) as! [Profile]
        } else {
            profileStatuses = defaultProfileStatuses
        }

        for profile in profileStatuses {
            let statusMenuItem = StatusMenuItem(profile: profile, statusItemController: self)
            menu.addItem(statusMenuItem.menuItem)
            statusMenuItems.append(statusMenuItem)
        }

        connectMenuItem = ConnectionMenuItem(statusItemController: self)
        menu.addItem(connectMenuItem.menuItem)

        preferencesMenuItem = PreferencesMenuItem(statusItemController: self)
        menu.addItem(preferencesMenuItem.menuItem)

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
        statusMenuItemsEnabled = true
    }

    func disableStatusMenuItems() {
        for item in statusMenuItems {
            item.disable()
        }
        statusMenuItemsEnabled = false
    }

    func refreshStatusMenuItems() {
        for item in statusMenuItems {
            menu.removeItem(item.menuItem)
        }
        statusMenuItems.removeAll()

        for (index, profile) in profileStatuses.enumerated() {
            let statusMenuItem = StatusMenuItem(profile: profile, statusItemController: self)
            if (statusMenuItemsEnabled) { statusMenuItem.enable() }
            menu.insertItem(statusMenuItem.menuItem, at: index)
            statusMenuItems.append(statusMenuItem)
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

func deleteTokenFromKeychain() {
    do {
        let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                             account: "slack-menu-status-token",
                                             accessGroup: KeychainConfiguration.accessGroup)
        try tokenItem.deleteItem()
    } catch {
        return;
    }
}
