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
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        // load messages

        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            self.welcomeLabel.text = "\(self.welcomeLabel.text!), \(email!)"
             
//            self.welcomeLabel.text = "\(self.welcomeLabel.text!), \(email!)"
                
          }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      Auth.auth().removeStateDidChangeListener(handle!)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
