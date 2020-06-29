//
//  HomeViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 26/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var handle: AuthStateDidChangeListenerHandle?
    let db = Firestore.firestore()
    
    var messages = [Message]()
    var UID: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadMessages()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.UID = user.uid
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func sendButtonPress(_ sender: Any) {
                
        var ref: DocumentReference? = nil
        ref = db.collection("messages").addDocument(data: [
            "message": messageTextField.text!,
            "senderUID": self.UID,
            "time": Timestamp(date: Date()),
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.messageTextField.text = ""
                self.loadMessages()
            }
        }
        
    }
    
    
    // add counter to messages for ordering..
    
    func loadMessages() {
        self.messages = [Message]()
        
        let collection = db.collection("messages")
        collection.order(by: "time", descending: false)
        
        collection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let msg = document.data()["message"]! as! String
                    let uid = document.data()["senderUID"]! as! String
                    self.messages.append(Message(uid, msg))
                    print("message: \(document.data()["message"]!)")
    
                }
            }
            self.tableView.reloadData()
        }
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) // for reusability
        cell.textLabel?.text = messages[indexPath.row].message
        cell.textLabel?.numberOfLines = 0
        
        if messages[indexPath.row].senderUID == self.UID {
            cell.textLabel?.textAlignment = NSTextAlignment.right
        } else {
            cell.textLabel?.textAlignment = NSTextAlignment.left
        }
         
        return cell
    }
}
