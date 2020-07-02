//
//  AddContactViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 01/07/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class AddContactViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    var users = [User]()
    var contacts = [User]() 
    var contactsNames = Set<String>()
    
    
    var UID = ""
    var USERNAME = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        searchBar.searchTextField.autocorrectionType = .no
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.searchTextField.spellCheckingType = .no
        
        feedbackLabel.text = ""
        
        let user = Auth.auth().currentUser
        if let user = user {
            self.UID = user.uid
            self.db.collection("users").document(self.UID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.USERNAME = document.data()!["username"] as! String
                    }
                    else {
                        print("Document does not exist")
                    }
            }
            
        }
        
        for user in contacts {
            contactsNames.insert(user.username)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        db.collection("users").order(by: "username").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                self.users = [User]()
                
                for document in querySnapshot!.documents {
                    let userID = document.documentID
                    let user = document.data()
                    let name = user["username"] as! String
                    let active = (user["active"] as? Int == 1 ? true : false)
                    
                    if userID != self.UID && !self.contactsNames.contains(name) &&
                        name.uppercased().contains(searchText.uppercased())
                    {
                        self.users.append(User(UID: userID, username: name, active: active))
                    }
                }
            }
            self.tableView.reloadData()
        }
        
    }
    

    func sendRequestAction(at indexPath: IndexPath) -> UIContextualAction {
        let user = users[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "sendRequest") {(action, view, completion) in

            let ref = self.db.collection("users").document(user.UID)

            ref.updateData([
                "requests": FieldValue.arrayUnion([[ "UID": self.UID, "username": self.USERNAME ]])
            ])
            
            self.feedbackLabel.text = "Request sent!"
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                self.feedbackLabel.text = ""
            }
            
        }
        action.image = UIImage(systemName: "plus.circle")
        action.backgroundColor = UIColor.systemGreen
        
        return action
    }
    
    // TODO: View Profile
    func viewProfileAction(at indexPath: IndexPath) -> UIContextualAction {
//        let user = users[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "viewProfile") {(action, view, completion) in
            print("TODO: view profile..")
            completion(true)
        }
        action.image = UIImage(systemName: "person.crop.circle")
        action.backgroundColor = UIColor.systemGray

        return action
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sendRequest = sendRequestAction(at: indexPath)
        let viewProfile = viewProfileAction(at: indexPath)

        return UISwipeActionsConfiguration(actions: [sendRequest, viewProfile])
    }
    
    
}


extension AddContactViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
}


