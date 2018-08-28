//
//  Profile.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Foundation.NSURL

func lookupKnownEmojiCode(shortcode: String) -> Character {
    var emojiCode: Character?
    switch (shortcode) {
    case ":office:":
        emojiCode = "\u{1F3E2}"
        break
    case ":house_with_garden:":
        emojiCode = "\u{1F3E1}"
        break
    case ":no_entry_sign:":
        emojiCode = "\u{1F6AB}"
        break
    default:
        emojiCode = "\u{2753}"
    }
    return emojiCode!
}

class Profile {
    var statusText: String
    var statusEmoji: String
    var emojiCode: Character {
        didSet {
            let emojiValue = self.emojiCode.unicodeScalars.first!.value
            self.recognizedEmoji = emojiValue > 0xE000 && emojiValue < 0x10FFFF
        }
    }
    var recognizedEmoji: Bool = true
    
    init(statusText: String, statusEmoji: String, emojiCode: Character! = nil) {
        self.statusText = statusText
        self.statusEmoji = statusEmoji
        if (emojiCode == nil) {
            self.emojiCode = lookupKnownEmojiCode(shortcode: statusEmoji)
        } else {
            self.emojiCode = emojiCode
        }
    }
}
