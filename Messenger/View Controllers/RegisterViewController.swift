//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 26/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButtonPress(_ sender: Any) {
        
        Auth.auth().createUser(
            withEmail: emailTextField.text!,
            password: passwordTextField.text!,
            completion: { (result, error) -> Void in
                
            if (error == nil) {
                
                print("Account created :)")
                
                let db = Firestore.firestore()
                db.collection("users").addDocument(data:
                    ["email" : self.emailTextField.text!,
                     "username": self.usernameTextField.text!]) { (error) in
                        if error != nil {
                            print("Failed to store user data")
                        }
                }
                
                // transition
                let home = self.storyboard?.instantiateViewController(identifier: "home") as? HomeViewController
                self.view.window?.rootViewController = home
                self.view.window?.makeKeyAndVisible()
                
            }
            else {
                print(error!)
            }
        })
        
        
    }
    
}
