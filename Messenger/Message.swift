//
//  Message.swift
//  Messenger
//
//  Created by Zan Spiler on 28/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import Foundation
import MessageKit

//class Message {
//    var senderUID: String
//    var message: String
//
//    init(_ uid: String, _ message: String) {
//        self.senderUID = uid
//        self.message = message
//    }
//}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
