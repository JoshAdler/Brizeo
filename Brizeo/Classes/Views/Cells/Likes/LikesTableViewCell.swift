//
//  LikesTableViewCell.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/6/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol LikesTableViewCellDelegate: class {
    func likesCell(cell: LikesTableViewCell, didClickedApprove likerView: LikerView)
    func likesCell(cell: LikesTableViewCell, didClickedDecline likerView: LikerView)
}

class LikesTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var profileLogoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likesView: LikerView!
    weak var delegate: LikesTableViewCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if profileLogoImageView != nil {
            profileLogoImageView.layer.cornerRadius = profileLogoImageView.frame.width / 2.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onApproveButtonClicked(_ sender: UIButton) {
        delegate?.likesCell(cell: self, didClickedApprove: likesView)
    }
    
    @IBAction func onDeclineButtonClicked(_ sender: UIButton) {
        delegate?.likesCell(cell: self, didClickedDecline: likesView)
    }
}
