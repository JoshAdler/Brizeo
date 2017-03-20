//
//  LikesTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol LikesTableViewCellDelegate: class {
    func likesCell(cell: LikesTableViewCell, didClickedProfile button: UIButton)
}

class LikesTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var profileLogoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton! {
        didSet {
            profileButton.setTitle(LocalizableString.Profile.localizedString, for: .normal)
            profileButton.layer.cornerRadius = 5.0
//            profileButton.layer.borderWidth = 1.0
//            profileButton.layer.borderColor = HexColor("")
        }
    }
    weak var delegate: LikesTableViewCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if profileLogoImageView != nil {
            profileLogoImageView.layer.cornerRadius = profileLogoImageView.frame.width / 2.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onProfileButtonClicked(_ sender: UIButton) {
        delegate?.likesCell(cell: self, didClickedProfile: sender)
    }
}
