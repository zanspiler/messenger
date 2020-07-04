////
////  HomeViewController.swift
////  Messenger
////
////  Created by Zan Spiler on 26/06/2020.
////  Copyright © 2020 Zan Spiler. All rights reserved.
////

import UIKit
import Firebase
import FirebaseStorage
import MessageKit
import InputBarAccessoryView


struct Sender: SenderType {
    var senderId: String
    var UID: String
    var displayName: String
}


class ChatViewController: MessagesViewController, MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate, InputBarAccessoryViewDelegate {
            
    let db = Firestore.firestore()
    
    var loggedInUser: Sender?
    var loggedInUID = ""
    var loggedInUsername = ""
    var loggedInProfilePicture: UIImage?

    var contact: User?
    var conversationID = ""
    
    var messageId = 42
    var messages = [Message]()
    
    
    let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.center = view.center
        messagesCollectionView.addSubview(spinner)
        spinner.startAnimating()
        
        // Get logged in user's data and load conversation
        
        let user = Auth.auth().currentUser
        if let user = user {
            self.loggedInUID = user.uid
            self.db.collection("users").document(self.loggedInUID).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.loggedInUsername = document.data()!["username"] as! String
                    self.loggedInUser = Sender(senderId: self.loggedInUID, UID: self.loggedInUID, displayName: self.loggedInUsername)
                
                    let storageRef = Storage.storage().reference().child("profilePictures/\(self.loggedInUID).png")
                    storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if error == nil {
                            if let image = UIImage(data: data!) {
                                self.loggedInProfilePicture = image
                            }
                            self.setConversationID()
                            self.loadMessages()
                        }
                        else {
                            print(error!)
                        }
                    }
                    
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Listen for new messages
        db.collection("messages").addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.setConversationID()
            self.loadMessages()
        }
    }

    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if trimmedText == "" { return }
        
        var ref: DocumentReference? = nil
        ref = db.collection("conversations").document(conversationID).collection("messages").addDocument(data: [
            "message": trimmedText,
            "senderUID": self.loggedInUID,
            "senderUsername": self.loggedInUsername,
            "time": Timestamp(date: Date()),
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                self.messages.append(Message(sender: self.loggedInUser!, messageId: String(self.messageId), sentDate: Date(), kind: .text(text)))
                self.messageId += 1
                self.messagesCollectionView.reloadData()
                inputBar.inputTextView.text = ""
                self.messagesCollectionView.scrollToBottom()
            }
        }
        
    }
    
    func loadMessages() {
        self.messages = [Message]()
        
        db.collection("conversations").document(conversationID).collection("messages").order(by: "time").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let messageText = document.data()["message"]! as! String
                    let senderName = document.data()["senderUsername"]! as! String
                    let senderUID = document.data()["senderUID"]! as! String

                    let date: Date = (document.data()["time"] as! Timestamp).dateValue()
                    
                    self.messages.append(Message(sender: Sender(senderId: senderUID, UID: senderUID, displayName: senderName),
                                                 messageId: document.documentID,
                                                 sentDate: date,
                                                 kind: .text(messageText)
                                                 ))
                }
            }
            self.messagesCollectionView.reloadData()
            self.spinner.stopAnimating()
        }

    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let image = (message.sender.senderId == loggedInUID ? loggedInProfilePicture : contact?.profilePicture!)
        avatarView.set(avatar: Avatar(image: image, initials: message.sender.senderId))
    }
    
    
    func setConversationID() {
        if loggedInUsername < contact!.username {
            conversationID = loggedInUsername + "-" + contact!.username
        } else {
            conversationID = contact!.username + "-" + loggedInUsername
        }
    }
    
    
    
    // TableView functions
    
    func currentSender() -> SenderType {
        return loggedInUser!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    
    // Functions for displaying username
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let style = NSMutableParagraphStyle()
        style.alignment = (name == loggedInUsername ? NSTextAlignment.right : NSTextAlignment.left)
        
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
                .paragraphStyle: style
            ]
        )
    }
}
