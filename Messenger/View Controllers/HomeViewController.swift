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
    
    var handle: AuthStateDidChangeListenerHandle?
    var UID: String = ""
    var USERNAME: String = ""
    
    var users = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.UID = user.uid
                self.db.collection("users").document(self.UID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.USERNAME = document.data()!["username"] as! String
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
        
        db.collection("users").order(by: "username").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    let usr = document.data()["username"] as! String
                    if usr != self.USERNAME { self.users.append(usr) }
                }
            }
            self.tableView.reloadData()
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
  
}


extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell tap
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

