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
    @IBOutlet weak var logoutButton: UIButton!
    
    let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))

    
    let db = Firestore.firestore()
    
    var UID: String = ""
    var USERNAME: String = ""
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        spinner.center = view.center
        view.addSubview(spinner)
        
        self.spinner.startAnimating()
        
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
    

    @IBAction func logoutButtonPress(_ sender: Any) {
        
            // Log out user and change user's status
            let user = Auth.auth().currentUser
            if let user = user {
                Firestore.firestore().collection("users").document(user.uid).updateData([
                    "active": false
                ]) { err in
                    if err != nil {
                        print("Error updating user status")
                    } else {
                        print("User status updated")
                        do {
                            try Auth.auth().signOut()
                        } catch { print("Error trying to Log Out") }
                    }
                }
            }

            // Transition to Home View
              let firstScreen = self.storyboard?.instantiateViewController(identifier: "first") as? ViewController
              self.view.window?.rootViewController = firstScreen
              self.view.window?.makeKeyAndVisible()                        
    }

    // Prepare for transfer of data to Chat VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToChat" {
            let destinationViewController = segue.destination as! ChatViewController
            destinationViewController.contactName = sender as? String
        }
    }
    
    
    func loadUsers() {
        users = [User]()
        
        db.collection("users").order(by: "username").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let userID = document.documentID
                    let user = document.data()
                    let name = user["username"] as! String
                    let active = (user["active"] as? Int == 1 ? true : false)
            
                    if name != self.USERNAME {
                        self.users.append(User(UID: userID, username: name, active: active))
                    }
                }
            }
            self.spinner.stopAnimating()
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
        cell.textLabel?.text = users[indexPath.row].username 
        
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.contentView.backgroundColor = UIColor.white
        
        return cell
    }
    
}

