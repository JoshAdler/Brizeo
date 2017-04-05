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
    
    // MARK: - Public methods
    
    func applyUser(user: User) {
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
