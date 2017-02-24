//
//  MatchProfilePictureCollectionViewCell.swift
//  Brizeo
//
//  Created by Arturo on 4/21/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

class MatchProfilePictureCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playIconImageView: UIImageView!
    
    var isPlayIconHidden: Bool {
        get {
            return playIconImageView.isHidden
        }
        set {
            playIconImageView.isHidden = newValue
        }
    }
}
