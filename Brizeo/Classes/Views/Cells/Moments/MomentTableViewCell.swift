//
//  MomentCell.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/4/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol MomentTableViewCellDelegate: class {
    
    func momentCellDidSelectLike(_ cell: MomentTableViewCell)
    func momentCellDidSelectMomentLikes(_ cell: MomentTableViewCell)
    func momentCellDidSelectOwnerProfile(_ cell: MomentTableViewCell)
    func momentCellDidSelectMoreOptions(_ cell: MomentTableViewCell)
}

class MomentTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var momentImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var momentDescriptionLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var notificationView: UILabel!
    @IBOutlet weak var ownerLogoButton: UIButton! {
        didSet {
            ownerLogoButton.layer.borderWidth = 2.0
            ownerLogoButton.layer.borderColor = HexColor("e1ee11")?.cgColor
        }
    }
    @IBOutlet weak var numberOfLikesButton: UIButton! {
        didSet {
            numberOfLikesButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            numberOfLikesButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            numberOfLikesButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }
    
    weak var delegate: MomentTableViewCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // set corner radius
        if notificationView != nil {
            notificationView.layer.cornerRadius = notificationView.frame.height / 2.0
        }
        
        if ownerLogoButton != nil {
            ownerLogoButton.layer.cornerRadius = ownerLogoButton.frame.height / 2.0
        }
    }

    //MARK: - Actions
    
    @IBAction fileprivate func onLikeButtonClicked(_ sender: UIButton) {
        delegate?.momentCellDidSelectLike(self)
    }
    
    @IBAction fileprivate func onLikesButtonClicked(_ sender: UIButton) {
        delegate?.momentCellDidSelectMomentLikes(self)
    }
    
    @IBAction fileprivate func onProfileButtonClicked(_ sender: UIButton) {
        delegate?.momentCellDidSelectOwnerProfile(self)
    }
    
    @IBAction fileprivate func onMoreOptionsButtonClicked(_ sender: UIButton) {
        delegate?.momentCellDidSelectMoreOptions(self)
    }
    
    // MARK: - Public methods
    
    func setButtonHighligted(isHighligted: Bool) {
        likeButton.isSelected = isHighligted
    }
}
