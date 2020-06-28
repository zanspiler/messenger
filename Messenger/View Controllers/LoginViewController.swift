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

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonPress(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error == nil {
                //transition
                let home = self.storyboard?.instantiateViewController(identifier: "home") as? HomeViewController
                self.view.window?.rootViewController = home
                self.view.window?.makeKeyAndVisible()
                
            }
            else {
                print(error!)
            }
        }
        
    }


}
