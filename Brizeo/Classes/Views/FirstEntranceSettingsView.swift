//
//  FirstEntranceMomentView.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class FirstEntranceSettingsView: UIView {
    
    // MARK: - Properties

    @IBOutlet weak var backImageView: UIImageView! {
        didSet {
            backImageView.image = #imageLiteral(resourceName: "bg_popup_settings_back").withRenderingMode(.alwaysTemplate)
        }
    }

    @IBOutlet weak var searchLocationImageView: UIImageView! {
        didSet {
            searchLocationImageView.image = #imageLiteral(resourceName: "bg_popup_settings_searchLocation").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var searchNationalityImageView: UIImageView! {
        didSet {
            searchNationalityImageView.image = #imageLiteral(resourceName: "bg_popup_settings_nationality").withRenderingMode(.alwaysTemplate)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onHideButtonClicked(sender: UIButton) {
        
        hide()
    }
    
    // MARK: - Public methods
    
    func hide() {
        
        removeFromSuperview()
    }
}
