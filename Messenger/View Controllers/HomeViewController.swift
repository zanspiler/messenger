//
//  HomeViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 29/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var UID: String = ""
    var USERNAME: String = ""
    
    var users = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load list of all users excluding logged-in user
        let user = Auth.auth().currentUser
        if let user = user {
            self.UID = user.uid
            self.db.collection("users").document(self.UID).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.USERNAME = document.data()!["username"] as! String
                    self.loadUsers()
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    // Prepare for transfer of data to Chat VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToChat" {
            let destinationViewController = segue.destination as! ChatViewController
            destinationViewController.contactName = sender as? String
        }
    }
    
    func loadUsers() {
        users = [String]()
        
        db.collection("users").order(by: "username").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let usr = document.data()["username"] as! String
                    if usr != self.USERNAME {
                        self.users.append(usr)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
}


extension HomeViewController: UITableViewDelegate {
    // Tap on user's name
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        // Send data to Chat VC
        performSegue(withIdentifier: "HomeToChat", sender: user)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) // for reusability
        cell.textLabel?.text = users[indexPath.row]
        
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.contentView.backgroundColor = UIColor.white
        
        return cell
    }
    
}

