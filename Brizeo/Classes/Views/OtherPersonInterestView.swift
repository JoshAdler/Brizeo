//
//  OtherPersonInterestView.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class OtherPersonInterestView: UIView {

    // MARK: - Types
    
//    struct Constants {
//        static let colorAlpha: CGFloat = 0.65
//    }
    
    // MARK: - Properties
    
    @IBOutlet weak var interestImageView: UIImageView!
    @IBOutlet weak var interestTitleLabel: UILabel!

    // RB Comment: Old functionality. Now it is always black opacity 65%
//    var interestColor: UIColor {
//        get {
//            return backgroundColor ?? .white
//        }
//        set {
//            backgroundColor = newValue.withAlphaComponent(Constants.colorAlpha)
//        }
//    }
    
//    var title: String? {
//        get {
//            return interestTitleLabel.text
//        }
//        set {
//            interestTitleLabel.text = newValue
//        }
//    }

    // RB Comment: Now it is always star
//    var image: UIImage? {
//        get {
//            return interestImageView.image
//        }
//        set {
//            interestImageView.image = newValue
//        }
//    }
    
    // MARK: - Public methods
    
    func showSharedCount(_ count: Int) {
        
        guard count > 0 else {
            isHidden = true
            return
        }
        
        let text = "\(count) Shared Interest\(count > 1 ? "s" : "")"
        interestTitleLabel.text = text
    }
}
