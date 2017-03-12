//
//  PersonalTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit

class PersonalTabsViewController: BasicViewController {

    // MARK: - Types
    
    struct Constants {
        static let titles = [LocalizableString.Profile.localizedString.capitalized, LocalizableString.Settings.localizedString.capitalized]
        static let profileControllerId = "ProfileViewController"
        static let settingsControllerId = "SettingsViewController"
        static let detailsControllerId = "PersonalDetailsTabsViewController"
        static let detailsSegueId = "showPersonalDetails"
    }
    
    // MARK: - Properties
    
    var profileController: ProfileViewController!
    var settingsController: SettingsViewController!
    var detailsController: PersonalDetailsTabsViewController!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load controller
        profileController = Helper.controllerFromStoryboard(controllerId: Constants.profileControllerId)!
        profileController.delegate = self
        
        settingsController = Helper.controllerFromStoryboard(controllerId: Constants.settingsControllerId)!
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
    }
    
    // MARK: - Actions
    
    @IBAction override func onBackButtonClicked(sender: UIBarButtonItem) {
        
        if FirstEntranceProvider.shared.isFirstEntrancePassed == false && FirstEntranceProvider.shared.currentStep == .profile {
            // show force screen
        } else {
            super.onBackButtonClicked(sender: sender)
        }
    }
    
}

// MARK: - ProfileViewControllerDelegate
extension PersonalTabsViewController: ProfileViewControllerDelegate {
    
    func shouldShowDetails() {
        if detailsController == nil {
            detailsController = Helper.controllerFromStoryboard(controllerId: Constants.detailsControllerId)!
            detailsController.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - profileController.bottomSpaceHeight), size: CGSize(width: view.frame.width, height: view.frame.height))
        }
        
        view.addSubview(detailsController.view)
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.detailsController.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        }) { (isFinished) in
            self.detailsController.didControllerChangedPosition(isOpened: true, completionHandler: nil)
        }
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension PersonalTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return profileController
        } else {
            return settingsController
        }
    }
}
