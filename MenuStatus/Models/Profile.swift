//
//  Profile.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Foundation.NSURL

class Profile {
    let statusText: String
    let statusEmoji: String
    
    init(statusText: String, statusEmoji: String) {
        self.statusText = statusText
        self.statusEmoji = statusEmoji
    }
}
