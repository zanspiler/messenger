//
//  AddContactViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 01/07/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class AddContactViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    var contacts = [User]() 
    var contactsNames = Set<String>()

    
    var UID = ""
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Custom Cell
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserTableViewCell")
        
        searchBar.searchTextField.autocorrectionType = .no
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.searchTextField.spellCheckingType = .no

        
        let user = Auth.auth().currentUser
        if let user = user {
            self.UID = user.uid
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    

}

extension AddContactViewController: UITableViewDelegate {
    // Tap on user's name
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row].username
        // Send data to Chat VC
        performSegue(withIdentifier: "HomeToChat", sender: user)
    }
}

extension AddContactViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        
        cell.label?.text = users[indexPath.row].username
        cell.label?.textAlignment = NSTextAlignment.left
        cell.statusImageView.backgroundColor = (users[indexPath.row].active ? UIColor.green : UIColor.red)
        cell.contentView.backgroundColor = UIColor.white
        
        cell.statusImageView.layer.borderWidth = 0
        cell.statusImageView.layer.cornerRadius = cell.statusImageView.frame.height/2
        
        return cell
    }
    
}
