//
//  PreferencesWindowController.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 8/21/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.window?.orderOut(sender)
        return false
    }
}


