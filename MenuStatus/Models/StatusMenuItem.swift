//
//  StatusMenuItem.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/20/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Foundation
import Cocoa

class StatusMenuItem {
    let profile: Profile
    var menuItem: NSMenuItem
    var statusItemController: StatusItemController

    init(profile: Profile, statusItemController: StatusItemController) {
        self.statusItemController = statusItemController
        self.profile = profile
        menuItem = NSMenuItem()
        menuItem.title = "\(profile.emojiCode()) \(profile.statusText)"
        menuItem.target = self
        menuItem.action = #selector(statusItemAction)
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = false
        menuItem.representedObject = profile
    }

    func enable() {
        menuItem.isEnabled = true
    }

    func disable() {
        menuItem.isEnabled = false
    }

    func refresh() {
        menuItem.title = "\(profile.emojiCode()) \(profile.statusText)"
    }

    @objc func statusItemAction(sender: AnyObject) {
        NSLog("statusItemAction called")
        let newProfile = sender.representedObject as? Profile
        SlackService.shared.setProfile(statusText: newProfile!.statusText, statusEmoji: newProfile!.statusEmoji) { result, errorMessage in
            if let result = result {
                self.statusItemController.profile = result
            }
        }
    }
}
