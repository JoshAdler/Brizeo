//
//  ProfileView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/8/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage

class ProfileView: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var interestView: OtherPersonInterestView!
    var currentUserId: String?
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedMutualFriendsNotification(notification:)), name: NSNotification.Name(rawValue: mutualFriendsNotification), object: nil)
        
        layer.borderColor = HexColor("F6F6F6")!.cgColor
        layer.borderWidth = 1.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    @objc fileprivate func didReceivedMutualFriendsNotification(notification: UIKit.Notification) {
        
        guard currentUserId != nil else {
            return
        }
        
        if let userInfo = notification.userInfo as? [String: Any] {
            let friends = userInfo["mutualFriends"] as? [User]
            let userId = userInfo["userId"] as? String? ?? "-1"
            
            if userId == currentUserId {
                setMutualFriendsCount(count: friends?.count ?? 0)
            }
        }
    }
    
    // MARK: - Public methods
    
    func applyUser(user: User) {
        currentUserId = user.objectId
        nameLabel.text = "\(user.shortName/*displayName*/), \(user.age)"
        
        if user.hasProfileImage {
            profileImageView.sd_setImage(with: user.profileUrl!)
        } else {
            profileImageView.image = nil
        }
        
        // study
        studyLabel.text = user.studyInfo ?? "Not set"
        
        // work
        workLabel.text = user.workInfo ?? "Not set"
    }
    
    func setInterest(with color: UIColor?, title: String?, image: UIImage?) {
        if let color = color {
            interestView.interestColor = color
        } else {
            interestView.interestColor = .clear
        }
        
        interestView.title = title
        interestView.image = image
    }
    
    func setInterest(with color: UIColor?, title: String?, imageURL: String?) {
        if let color = color {
            interestView.interestColor = color
        } else {
            interestView.interestColor = .clear
        }
        
        interestView.title = title
        
        if let imageURL = imageURL {
            interestView.interestImageView.sd_setImage(with: URL(string: imageURL)!)
        }
    }
    
    func setMutualFriendsCount(count: Int) {
        friendsCountLabel.text = "\(count)"
    }
}
