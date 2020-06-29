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
                
                let db = Firestore.firestore()
                
                // Store user in Users collection
                db.collection("users").document(result!.user.uid).setData([
                    "username": self.usernameTextField.text!,
                    "email": self.emailTextField.text!
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                
                print("User document created!")

                // Transition to Home View
                let home = self.storyboard?.instantiateViewController(identifier: "home") as? ChatViewController
                self.view.window?.rootViewController = home
                self.view.window?.makeKeyAndVisible()
                
            }
            else {
                print(error!)
            }
        })
        
        
    }
    
}
