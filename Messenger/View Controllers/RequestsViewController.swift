//
//  RequestsViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 02/07/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class RequestsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    let db = Firestore.firestore()
    var UID = ""
    var USERNAME = ""
    var requests = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.feedbackLabel.text = ""
        
        let user = Auth.auth().currentUser
        if let user = user {
            self.UID = user.uid
            loadRequests()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            
        let homeVC = (self.view.window!.rootViewController! as! HomeViewController)
        homeVC.loadContacts()
    }
    
    func loadRequests() {
        self.db.collection("users").document(self.UID).getDocument { (document, error) in
            if let document = document, document.exists {
                self.USERNAME = document.data()!["username"] as! String
               
                let reqs = document.data()!["requests"]! as! [Any]
                for req in reqs {
                    let req = req as! [String: Any]
                    let id = req["UID"]!
                    let name = req["username"]!
                    self.requests.append(User(id as! String, name as! String))
                }
                
                self.tableView.reloadData()
            }
            else {
                print("Document does not exist")
            }
        }
    }
    
    func acceptRequestAction(at indexPath: IndexPath) -> UIContextualAction {
        let request = requests[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "acceptRequest") {(action, view, completion) in
            
            let loggedInUserRef = self.db.collection("users").document(self.UID)
            let newContactRef = self.db.collection("users").document(request.UID)
            
            // Add contact to logged-in user's contacts and remove the request
            loggedInUserRef.updateData([
                "contacts": FieldValue.arrayUnion([newContactRef]),
                "requests": FieldValue.arrayRemove([["username": request.username, "UID": request.UID]])
            ])
            
            // Add logged-in user to sender's contacts
            newContactRef.updateData([
                "contacts": FieldValue.arrayUnion([loggedInUserRef])
            ])
            
            // Set feedback text
            self.feedbackLabel.textColor = UIColor.systemGreen
            self.feedbackLabel.text = "Request accepted!"
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                self.feedbackLabel.text = ""
            }
            
            self.requests.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        action.image = UIImage(systemName: "checkmark.rectangle.fill")
        action.backgroundColor = UIColor.systemGreen
        
        return action
    }
    
    func rejectRequestAction(at indexPath: IndexPath) -> UIContextualAction {
        let request = requests[indexPath.row]
        
        let action = UIContextualAction(style: .normal, title: "rejectRequest") {(action, view, completion) in
            
            // Remove request
            let ref = self.db.collection("users").document(self.UID)
            ref.updateData([
                "requests": FieldValue.arrayRemove([["username": request.username, "UID": request.UID]])
            ])
            
            // Set feedback text
            self.feedbackLabel.textColor = UIColor.systemRed
            self.feedbackLabel.text = "Request rejected!"
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
                self.feedbackLabel.text = ""
            }
                        
            self.requests.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        action.image = UIImage(systemName: "clear.fill")
        action.backgroundColor = UIColor.systemRed
        
        return action
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acceptRequest = acceptRequestAction(at: indexPath)
        let rejectRequest = rejectRequestAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [acceptRequest, rejectRequest])
    }
    
}

extension RequestsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = requests[indexPath.row].username
        return cell
    }
    
}

