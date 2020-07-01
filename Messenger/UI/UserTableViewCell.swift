//
//  UserTableViewCell.swift
//  Messenger
//
//  Created by Zan Spiler on 30/06/2020.
//  Copyright © 2020 Zan Spiler. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var statusImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
