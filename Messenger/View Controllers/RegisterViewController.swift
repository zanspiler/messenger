//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Zan Spiler on 26/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.text = ""
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onProfilePictureSelect)))
        profilePicture.isUserInteractionEnabled = true
//        profilePicture.contentMode = .scaleAspectFill
//        profilePicture.translatesAutoresizingMaskIntoConstraints = false
//
        spinner.center = view.center
        view.addSubview(spinner)
    }
    
    @objc func onProfilePictureSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let edited = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] {
            selectedImage = edited as? UIImage
        }
        else if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] {
            selectedImage = image as? UIImage
        }
        
        if selectedImage != nil {
            profilePicture.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func registerButtonPress(_ sender: Any) {
        
        let trimmedEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for empty fields
        if !(trimmedEmail != "" && trimmedUsername != "" && passwordField.text! != "") {
            self.errorLabel.text = "Please fill all fields"
            return
        }
        
        // Check if username is valid
        if !validateUsername() { return }
        
        
        // Check if account with username already exists
        db.collection("users").whereField("username", isEqualTo: usernameField.text!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if !querySnapshot!.isEmpty {
                        self.errorLabel.text = "Username exists"
                        return
                    }
                    else {
                        self.spinner.startAnimating()
                        self.registerUser()
                    }
                }
        }
         
    }
    
    
    @IBAction func backButtonPress(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    func registerUser() {
        Auth.auth().createUser(
            withEmail: emailField.text!,
            password: passwordField.text!,
            completion: { (result, error) -> Void in
                
                if (error == nil) {
                    // Upload profile picture
                    let storageRef = Storage.storage().reference().child("profilePictures/\(result!.user.uid).png")
                    
                    if let uploadData = self.profilePicture.image!.pngData() {
                        storageRef.putData(uploadData, metadata: nil) { (metadata, errir) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            // Get profile picture URL and save new User in database
                            storageRef.downloadURL { (url, error) in
                                if url == nil {
                                    print(error!)
                                    return
                                }
                                self.saveUser(withUID: result!.user.uid, withPictureURL: url!.absoluteString)
                            }
                        }
                    }
                }
                    
                else {
                    self.errorLabel.text = self.errorMessage(with: error!._code)
                    self.spinner.stopAnimating()
                }
        })
    }
        
    // Saves new user to user collection and transitions to HomeVC
    func saveUser(withUID UID: String, withPictureURL URL: String) {
        self.db.collection("users").document(UID).setData([
            "username": self.usernameField.text!,
            "email": self.emailField.text!,
            "active": true,
            "contacts": [],
            "requests": []
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
                Utilities.setUserStatus(to: Constants.USER_STATUS_ACTIVE)
                
                // Transition to Home View
                let home = self.storyboard?.instantiateViewController(identifier: "home") as? HomeViewController
                self.view.window?.rootViewController = home
                self.view.window?.makeKeyAndVisible()
            }
        }
    }

    
    func validateUsername() -> Bool {
        if usernameField.text!.containsWhiteSpace() {
            self.errorLabel.text = "Username must not contain any spaces"
            return false
        }
        
        if usernameField.text!.count > 15 {
            self.errorLabel.text = "Username must be under 15 characters long"
            return false
        }
        
        return true
    }
    
    
    func errorMessage(with code: Int) -> String {
        switch code {
        case 17008: return "Please enter valid email address"
        case 17026: return "Password must be at least 6 characters long"
        case 17007: return "Account with given e-mail already exists"
        case 17009: return "Wrong password"
        case 17020: return "Network error"
        default: return "Error. Please try again"
        }
    }
    
}


extension String {
    func containsWhiteSpace() -> Bool {
        let range = self.rangeOfCharacter(from: .whitespacesAndNewlines)
        if let _ = range {
            return true
        } else {
            return false
        }
    }
}
