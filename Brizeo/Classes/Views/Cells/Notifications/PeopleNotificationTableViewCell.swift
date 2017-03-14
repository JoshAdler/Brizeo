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
        
        static let defaultFontSize: CGFloat = 12.0
        static let timeFontSize: CGFloat = 12.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTimeLabel: UILabel!
    @IBOutlet weak var commentUserImage: UIImageView!
    @IBOutlet weak var likesView: LikerView!
    weak var delegate: NotificationsTableViewCellDelegate?
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if commentUserImage != nil {
            commentUserImage.layer.cornerRadius = commentUserImage.frame.width / 2.0
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
    
    // MARK: - Actions
    
    @IBAction func onProfileButtonClicked(_ sender: UIButton) {
        delegate?.notificationCellDidClickedOnProfile(cell: self)
    }
    
    @IBAction func onImageButtonClicked(_ sender: UIButton) {
        delegate?.notificationCellDidClickedOnImage(cell: self)
    }
    
    @IBAction func onApproveButtonClicked(_ sender: UIButton) {
        delegate?.notificationCell(cell: self, didClickedApprove: likesView)
    }
    
    @IBAction func onDeclineButtonClicked(_ sender: UIButton) {
        delegate?.notificationCell(cell: self, didClickedDecline: likesView)
    }
}


