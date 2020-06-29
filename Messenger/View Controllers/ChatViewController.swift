//
//  HomeViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 26/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contactNameLabel: UILabel!
    
    let db = Firestore.firestore()
    
    var UID: String = ""
    var USERNAME: String = ""
    var contactName: String?
    var conversationID: String = ""
    
    var messages = [Message]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            self.UID = user.uid
            self.db.collection("users").document(self.UID).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.USERNAME = document.data()!["username"] as! String
                    self.setConversationID()
                    self.loadMessages()
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        contactNameLabel.text = contactName
        
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

    
    @IBAction func sendButtonPress(_ sender: Any) {
        let trimmedMsg = self.messageField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        if trimmedMsg == "" { return }
                
        var ref: DocumentReference? = nil
        ref = db.collection("conversations").document(conversationID).collection("messages").addDocument(data: [
            "message": messageField.text!,
            "senderUID": self.UID,
            "time": Timestamp(date: Date()),
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.messages.append(Message(self.UID, self.messageField.text!))
                self.updateTableView()
                self.messageField.text = ""
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
                    let msg = document.data()["message"]! as! String
                    let uid = document.data()["senderUID"]! as! String
                    self.messages.append(Message(uid, msg))
                }
            }
            self.updateTableView()
        }
        
    }
    
    func updateTableView() {
        self.tableView.reloadData()
        if self.messages.count > 0 {
            self.tableView.scrollToRow(at: NSIndexPath(row: self.messages.count-1, section: 0) as IndexPath, at: .bottom, animated: false)
        }
    }
    
    func setConversationID() {
        if USERNAME < contactName! {
            conversationID = USERNAME + "-" + contactName!
        } else {
            conversationID = contactName! + "-" + USERNAME
        }
    }
    
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell tap
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) // for reusability
        cell.textLabel?.text = messages[indexPath.row].message
        cell.textLabel?.numberOfLines = 0
        
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.contentView.backgroundColor = UIColor.white
        
        // user's message
        if messages[indexPath.row].senderUID == self.UID {
            cell.textLabel?.textAlignment = NSTextAlignment.right
        }
        
        return cell
    }
}
