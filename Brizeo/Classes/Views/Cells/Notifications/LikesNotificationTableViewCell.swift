//
//  LikeNotiTableViewCell.swift
//  Brizeo
//
//  Created by Mobile on 12/13/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class LikesNotificationTableViewCell: UITableViewCell {
    
    // MARK: - Types
    
    struct Constants {
        static let mainColor = UIColor.black
        static let timeColor = HexColor("a2a2a2")
        
        static let nameFontSize: CGFloat = 14.0
        static let defaultFontSize: CGFloat = 14.0
        static let timeFontSize: CGFloat = 14.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var likeUserImage: UIImageView!
    @IBOutlet weak var likedMomentImage: UIImageView!
    @IBOutlet weak var likeTextLabel: UILabel!
    @IBOutlet weak var viewedView: UIView!
    @IBOutlet weak var profileButton: UIButton! {
        didSet {
            profileButton.setTitle(LocalizableString.Profile.localizedString, for: .normal)
            profileButton.layer.cornerRadius = 5.0
        }
    }
    weak var delegate: NotificationsTableViewCellDelegate?
    
    var isAlreadyReviewed: Bool {
        get {
            return viewedView.isHidden
        }
        set {
            viewedView.isHidden = newValue
        }
    }
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if likeUserImage != nil {
            likeUserImage.layer.cornerRadius = likeUserImage.frame.width / 2.0
        }
        
        if viewedView != nil {
            viewedView.layer.cornerRadius = viewedView.frame.width / 2.0
        }
    }
    
    // MARK: - Public methods
    
    func generateText(with authorName: String, time: String) {
        let ownerNameAttributes = [NSForegroundColorAttributeName: Constants.mainColor, NSFontAttributeName:    UIFont(name: "SourceSansPro-Bold", size: Constants.nameFontSize)]
        let defaultAttributes = [NSForegroundColorAttributeName: Constants.mainColor, NSFontAttributeName: UIFont(name: /*"SourceSansPro-Regular"*/"SourceSansPro-Bold", size: Constants.defaultFontSize)]
        let timeAttributes = [NSForegroundColorAttributeName: Constants.timeColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Regular", size: Constants.timeFontSize)]
        
        let partOne = NSMutableAttributedString(string: authorName, attributes: ownerNameAttributes)
        let partTwo = NSMutableAttributedString(string: " \(LocalizableString.LikeNotificationMessage.localizedString)", attributes: defaultAttributes)
        let partThree = NSMutableAttributedString(string: "\n\(time)", attributes: timeAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partThree)
        
        likeTextLabel.attributedText = combination
    }
    
    // MARK: - Actions
    
    @IBAction func onProfileButtonClicked(_ sender: UIButton) {
        delegate?.notificationCellDidClickedOnProfile(cell: self)
    }
    
    @IBAction func onImageButtonClicked(_ sender: UIButton) {
        delegate?.notificationCellDidClickedOnImage(cell: self)
    }
    
    @IBAction func onProfileRightButtonClicked(_ sender: UIButton) {
        delegate?.notificationCellDidClickedOnProfile(cell: self)
    }
}
