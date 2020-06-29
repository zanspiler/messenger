//
//  Message.swift
//  Messenger
//
//  Created by Zan Spiler on 28/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import Foundation

class Message {
    
    var senderUID: String
    var message: String
    
    init(_ uid: String, _ message: String) {
        self.senderUID = uid
        self.message = message
    }
    
}
