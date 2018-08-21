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
    var menuItem: NSMenuItem

    init(profile: Profile, statusItemController: StatusItemController) {
        menuItem = NSMenuItem()
        menuItem.title = "\(profile.emojiCode()) \(profile.statusText)"
        menuItem.target = statusItemController
        menuItem.action = #selector(StatusItemController.statusItemAction)
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
}
