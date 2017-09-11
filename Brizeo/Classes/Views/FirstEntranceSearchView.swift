//
//  FirstEntranceMomentView.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class FirstEntranceSearchView: UIView {
    
    // MARK: - Properties

    @IBOutlet weak var passImageView: UIImageView! {
        didSet {
            passImageView.image = #imageLiteral(resourceName: "ic_popup_pass").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var connectImageView: UIImageView! {
        didSet {
            connectImageView.image = #imageLiteral(resourceName: "ic_popup_connect").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var moreDetailsImageView: UIImageView! {
        didSet {
            moreDetailsImageView.image = #imageLiteral(resourceName: "bg_popup_search_moreDetails").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var moreInfoImageView: UIImageView! {
        didSet {
            moreDetailsImageView.image = #imageLiteral(resourceName: "bg_popup_search_moreDetails").withRenderingMode(.alwaysTemplate)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onHideButtonClicked(sender: UIButton) {
        
        hide()
    }
    
    // MARK: - Public methods
    
    func setContentAvailable(_ isAvailable: Bool) {
        
        moreInfoImageView.isHidden = !isAvailable
        moreDetailsImageView.isHidden = !isAvailable
    }
    
    func hide() {
        
        removeFromSuperview()
    }
}
