//
//  Utilities.swift
//  Messenger
//
//  Created by Zan Spiler on 30/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import Foundation
import Firebase

class Utilities {
    
    static func setUserStatus(to status: String) {
        print("setting status...")
        let user = Auth.auth().currentUser
        if let user = user {
            Firestore.firestore().collection("users").document(user.uid).updateData([
                "active": (status == Constants.USER_STATUS_ACTIVE ? true : false)
            ]) { err in
                if err != nil {
                    print("Error updating user status")
                } else {
                    print("User status updated")
                }
            }
        }
                
    }
}
