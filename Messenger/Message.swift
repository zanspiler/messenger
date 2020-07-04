//
//  Message.swift
//  Messenger
//
//  Created by Zan Spiler on 28/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import Foundation
import MessageKit


struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
