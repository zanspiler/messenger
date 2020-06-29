//
//  LoginViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 26/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    @IBAction func loginButtonPress(_ sender: Any) {
        
        let trimmedEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check for empty fields
        if !(trimmedEmail != "" && passwordField.text! != "") {
            self.errorLabel.text = "Please fill all fields"
            return
        }
        
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (result, error) in
            if error == nil {
                // Transition to Home View
                let home = self.storyboard?.instantiateViewController(identifier: "home") as? HomeViewController
                self.view.window?.rootViewController = home
                self.view.window?.makeKeyAndVisible()
                
            }
            else {
                self.errorLabel.text = self.errorMessage(with: error!._code)
            }
        }
        
    }

    func errorMessage(with code: Int) -> String {
        switch code {
            case 17008: return "Please enter valid email address"
            case 17011: return "Account with given e-mail does not exist"
            case 17009: return "Wrong password"
            case 17020: return "Network error"
            default: return "Error"
        }
    }
    
}



