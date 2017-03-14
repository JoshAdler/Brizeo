//
//  UserMatchTableViewCell.swift
//  Brizeo
//
//  Created by Arturo on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SWTableViewCell

class UserMatchTableViewCell: SWTableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if avatarImageView != nil {
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2.0
        }
    }
}
