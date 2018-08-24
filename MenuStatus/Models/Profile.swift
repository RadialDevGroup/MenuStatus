//
//  Profile.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Foundation.NSURL

class Profile {
    var statusText: String
    var statusEmoji: String
    
    init(statusText: String, statusEmoji: String) {
        self.statusText = statusText
        self.statusEmoji = statusEmoji
    }

    func emojiCode() -> String {
        var iconString: String?
        switch (self.statusEmoji) {
        case ":office:":
            iconString = "\u{1F3E2}"
            break
        case ":house_with_garden:":
            iconString = "\u{1F3E1}"
            break
        case ":no_entry_sign:":
            iconString = "\u{1F6AB}"
            break
        default:
            iconString = "\u{2753}"
        }
        return iconString!
    }
}
