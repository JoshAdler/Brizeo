//
//  PeopleNotiTableViewCell.swift
//  Brizeo
//
//  Created by Mobile on 12/7/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class PeopleNotificationTableViewCell: UITableViewCell {
    
    // MARK: - Types
    
    struct Constants {
        static let mainColor = UIColor.black
        static let timeColor = HexColor("a2a2a2")
        
        static let defaultFontSize: CGFloat = 16.0
        static let timeFontSize: CGFloat = 16.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentUserImage: UIImageView!
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
        
        if commentUserImage != nil {
            commentUserImage.layer.cornerRadius = commentUserImage.frame.width / 2.0
        }
        
        if viewedView != nil {
            viewedView.layer.cornerRadius = viewedView.frame.width / 2.0
        }
    }
    
    // MARK: - Public methods
    
    func generateText(with friendName: String, _ nickname: String) {
        let defaultAttributes = [NSForegroundColorAttributeName: Constants.mainColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Regular", size: Constants.defaultFontSize)]
        let nameAttributes = [NSForegroundColorAttributeName: Constants.mainColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Bold", size: Constants.defaultFontSize)]

        let partOneString = LocalizableString.PeopleNotificationStart.localizedString + friendName + LocalizableString.PeopleNotificationEnd.localizedString
        let partOne = NSMutableAttributedString(string: partOneString, attributes: defaultAttributes)
        let partTwo = NSMutableAttributedString(string: " \(nickname)", attributes: nameAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        
        commentLabel.attributedText = combination
    }
    
    func generateMatchingText(with authorName: String, time: String, type: NotificationType) {
        
        let ownerNameAttributes = [NSForegroundColorAttributeName: Constants.mainColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Bold", size: Constants.defaultFontSize)]
        let defaultAttributes = [NSForegroundColorAttributeName: Constants.mainColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Regular", size: Constants.defaultFontSize)]
        let timeAttributes = [NSForegroundColorAttributeName: Constants.timeColor, NSFontAttributeName: UIFont(name: "SourceSansPro-Regular", size: Constants.timeFontSize)]
        
        let text = type == .newMatches ? LocalizableString.NotificationMatching : LocalizableString.NotificationWantMatching
        
        let partOne = NSMutableAttributedString(string: authorName, attributes: ownerNameAttributes)
        let partTwo = NSMutableAttributedString(string: " \(text.localizedString)", attributes: defaultAttributes)
        let partThree = NSMutableAttributedString(string: "\n\(time)", attributes: timeAttributes)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partThree)
        
        commentLabel.attributedText = combination
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


