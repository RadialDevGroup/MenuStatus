//
//  PreferencesMenuItem.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/21/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa

class PreferencesMenuItem {
    var preferencesController: NSWindowController?
    var menuItem: NSMenuItem
    var statusItemController: StatusItemController

    init(statusItemController: StatusItemController) {
        self.statusItemController = statusItemController
        menuItem = NSMenuItem()
        menuItem.title = "Preferences"
        menuItem.target = self
        menuItem.action = #selector(preferencesAction)
        menuItem.keyEquivalent = ""
        menuItem.isEnabled = true
    }

    @objc func preferencesAction(sender: AnyObject) {
        NSLog("preferencesAction called")

        if !(preferencesController != nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)

            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }

        if (preferencesController != nil) {
            preferencesController!.showWindow(sender)
        }
    }
}
