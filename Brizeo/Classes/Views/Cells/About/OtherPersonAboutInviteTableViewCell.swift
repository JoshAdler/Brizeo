//
//  OtherPersonAboutInviteTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol OtherPersonAboutInviteCellDelegate: class {
    func inviteCell(cell: OtherPersonAboutInviteTableViewCell, didClickedOnInvite button: UIButton)
}

class OtherPersonAboutInviteTableViewCell: UITableViewCell {

// MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton?
    weak var delegate: OtherPersonAboutInviteCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if logoImageView != nil {
            logoImageView.layer.cornerRadius = logoImageView.frame.height / 2.0
        }
    }
    
    // MARK: - Action
    
    @IBAction func onInviteButtonClicked(button: UIButton) {
        delegate?.inviteCell(cell: self, didClickedOnInvite: button)
    }
}
