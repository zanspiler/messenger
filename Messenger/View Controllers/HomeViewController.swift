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
    @IBOutlet weak var addContactButton: UIButton!
    
    let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    
    let db = Firestore.firestore()
    
    var UID: String = ""
    var USERNAME: String = ""
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom Cell
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserTableViewCell")
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        spinner.center = view.center
        view.addSubview(spinner)
        
        self.spinner.startAnimating()
        loadContacts()
    }
    
    @IBAction func logOutButtonPress(_ sender: Any) {
        
//          Log out user and change user's status
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
        
                // Transition to Login/Register View
                let firstScreen = self.storyboard?.instantiateViewController(identifier: "first") as? ViewController
                self.view.window?.rootViewController = firstScreen
                self.view.window?.makeKeyAndVisible()
    }
    

    
    @IBAction func addContactButtonPress(_ sender: Any) {
        // Send data to Chat VC
        performSegue(withIdentifier: "HomeToAddContact", sender: users)
    }
    
    // Prepare for transfer of data to Chat VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToChat" {
            let destinationViewController = segue.destination as! ChatViewController
            destinationViewController.contactUsername = sender as? String
        }
            
        else if segue.identifier == "HomeToAddContact" {
            let destinationViewController = segue.destination as! AddContactViewController
            destinationViewController.contacts = sender as! [User]
        }
    }
    
    
    func loadContacts() {
        let user = Auth.auth().currentUser
        if let user = user {
            self.UID = user.uid
            self.db.collection("users").document(self.UID).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.USERNAME = document.data()!["username"] as! String

                    self.users = [User]()
                    let docRefs = document.data()!["contacts"] as? [DocumentReference] ?? []
        
                    for docRef in docRefs {
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let userID = document.documentID
                                let user = document.data()
                                let name = user?["username"] as! String
                                let active = (user?["active"] as? Int == 1 ? true : false)
                                                                
                                if name != self.USERNAME {
                                    self.users.append(User(UID: userID, username: name, active: active))
                                    self.tableView.reloadData()
                                }
                                
                            } else {
                                print("Document does not exist")
                            }
                        }
                        
                    }
                self.spinner.stopAnimating()
                }
                else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
}


extension HomeViewController: UITableViewDelegate {
    // Tap on user's name
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row].username
        // Send data to Chat VC
        performSegue(withIdentifier: "HomeToChat", sender: user)
    }
}

extension HomeViewController: UITableViewDataSource {
    
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

