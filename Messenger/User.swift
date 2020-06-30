//
//  User.swift
//  Messenger
//
//  Created by Zan Spiler on 30/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import Foundation

class User {
    
    var UID: String
    var username: String
    var active: Bool
    
    init(UID: String, username: String, active: Bool) {
        self.UID = UID
        self.username = username
        self.active = active
    }
    
}

