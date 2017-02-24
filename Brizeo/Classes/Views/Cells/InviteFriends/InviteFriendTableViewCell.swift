//
//  InviteFriendTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/3/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class InviteFriendTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    var isChecked: Bool {
        get {
            return !checkmarkImageView.isHidden
        }
        set {
            checkmarkImageView.isHidden = !isChecked
        }
    }
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
    }
}
