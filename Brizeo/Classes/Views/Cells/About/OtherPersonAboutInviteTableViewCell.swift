//
//  OtherPersonAboutInviteTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class OtherPersonAboutInviteTableViewCell: UITableViewCell {

// MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        logoImageView.cornerRadius = logoImageView.frame.height / 2.0
    }
}
