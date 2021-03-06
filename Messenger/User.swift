//
//  User.swift
//  Messenger
//
//  Created by Zan Spiler on 30/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    var UID: String
    var username: String
    var active: Bool?
    var profilePicture: UIImage?
    
    init(UID: String, username: String, active: Bool) {
        self.UID = UID
        self.username = username
        self.active = active
    }
    
    init(_ UID: String, _ username: String) {
        self.UID = UID
        self.username = username
    }
    
}

