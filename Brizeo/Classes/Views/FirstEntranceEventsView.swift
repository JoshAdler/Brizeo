//
//  FirstEntranceMomentView.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

class FirstEntranceEventsView: UIView {

    // MARK: - Types
    
    struct Constants {
        static let cornerRadius: CGFloat = 5.0
        static let borderWidth: CGFloat = 1.0
    }
    
    // MARK: - Properties

    @IBOutlet weak var sortingImageView: UIImageView! {
        didSet {
            sortingImageView.image = #imageLiteral(resourceName: "bg_popup_events_sort").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var searchingImageView: UIImageView! {
        didSet {
            searchingImageView.image = #imageLiteral(resourceName: "bg_popup_events_search").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var momentsImageView: UIImageView! {
        didSet {
            momentsImageView.image = #imageLiteral(resourceName: "bg_popup_moments").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var profileGuideImageView: UIImageView! {
        didSet {
            profileGuideImageView.image = #imageLiteral(resourceName: "bg_popup_events_avatar").withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.borderColor = UIColor.black.cgColor
            profileImageView.layer.borderWidth = 2.0
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        }
    }
    
    @IBOutlet weak var filterButton: DropMenuButton! {
        didSet {
            filterButton.backgroundColor = UIColor.white
            filterButton.layer.cornerRadius = Constants.cornerRadius
            filterButton.layer.borderWidth = Constants.borderWidth
            filterButton.layer.borderColor = HexColor("cccccc")!.cgColor
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.backgroundColor = UIColor.white
            searchTextField.layer.cornerRadius = Constants.cornerRadius
            searchTextField.layer.borderWidth = Constants.borderWidth
            searchTextField.layer.borderColor = HexColor("cccccc")!.cgColor
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onHideButtonClicked(sender: UIButton) {
        
        hide()
    }
    
    // MARK: - Private methods
    
    fileprivate func setContentAvailable(_ isAvailable: Bool) {
        
        profileGuideImageView.isHidden = !isAvailable
        profileImageView.isHidden = !isAvailable
    }
    
    // MARK: - Public methods
    
    func setContentURL(_ url: URL?) {
        
        guard url != nil else {
            setContentAvailable(false)
            profileImageView.image = nil
            return
        }
        
        setContentAvailable(true)
        profileImageView.sd_setImage(with: url)
    }
    
    func hide() {
        
        removeFromSuperview()
    }
}
