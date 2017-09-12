//
//  FirstEntranceMomentView.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

protocol FirstEntranceUserViewDelegate: class {
    func userView(view: FirstEntranceUserView, didClickedOnArrowUp button: UIButton)
    func userView(view: FirstEntranceUserView, didClickedOnSettings button: UIButton)
}

class FirstEntranceUserView: UIView {

    // MARK: - Properties
    
    @IBOutlet fileprivate weak var settingView: UIView!
    @IBOutlet fileprivate weak var settingImageView: UIView!
    @IBOutlet fileprivate weak var arrowUpButton: UIButton!
    @IBOutlet fileprivate weak var profileImageView: UIView!
    @IBOutlet fileprivate weak var arrowUpButtonBottomConstraint: NSLayoutConstraint!
    weak var delegate: FirstEntranceUserViewDelegate?
    
    var bottomDistance: CGFloat {
        set {
            arrowUpButtonBottomConstraint.constant = newValue
        }
        get {
            return arrowUpButtonBottomConstraint.constant
        }
    }

    // MARK: - Public methods
    
    func update() {
        
        settingView.isHidden = true
        
        // hide "profile" attributes if needs
        if FirstEntranceProvider.shared.isAlreadyViewedProfilePreferences {
            
            arrowUpButton.isHidden = true
            profileImageView.isHidden = true
            settingView.isHidden = false
        }
        
        // hide "settings" attributes if needs
        if FirstEntranceProvider.shared.isAlreadyViewedSettings {
            
            settingImageView.isHidden = true
        }
    }
    // MARK: - Actions
    
    @IBAction func onArrowUpButtonClicked(sender: UIButton) {
        delegate?.userView(view: self, didClickedOnArrowUp: sender)
    }
    
    @IBAction func onSettingsButtonClicked(sender: UIButton) {
        delegate?.userView(view: self, didClickedOnSettings: sender)
    }
}
