////
////  MessagingViewController.swift
////  Messenger
////
////  Created by Zan Spiler on 01/07/2020.
////  Copyright © 2020 Zan Spiler. All rights reserved.
////
//
//import UIKit
//import MessageKit
//
//struct Sender: SenderType {
//    var senderId: String
//    var displayName: String
//}
//
//struct MessageItem: MessageType {
//    var sender: SenderType
//    var messageId: String
//    var sentDate: Date
//    var kind: MessageKind
//}
//
//class MessagingViewController: MessagesViewController, MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
//
//    let currentUser = Sender(senderId: "me", displayName: "Boy")
//    let otherUser = Sender(senderId: "other", displayName: "Girl")
//
//
//    var messages = [MessageType]()
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        messages.append(MessageItem(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello")))
//        messages.append(MessageItem(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-70000), kind: .text("Hello")))
//        messages.append(MessageItem(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-60400), kind: .text("bruh")))
//        messages.append(MessageItem(sender: otherUser, messageId: "4", sentDate: Date().addingTimeInterval(-40400), kind: .text("bruh")))
//        messages.append(MessageItem(sender: currentUser, messageId: "5", sentDate: Date().addingTimeInterval(-20400), kind: .text(":( :( :( :( :( :( :(")))
//
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        // Do any additional setup after loading the view.
//    }
//
//    func currentSender() -> SenderType {
//        return currentUser
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages[indexPath.row]
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//
//}
