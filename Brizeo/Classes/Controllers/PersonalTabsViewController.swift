//
//  PersonalTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit
import SVProgressHUD

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
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation!
    var blockButton: UIButton?
    var selectedIndex: Int?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load controller
        profileController = Helper.controllerFromStoryboard(controllerId: Constants.profileControllerId)!
        profileController.delegate = self
        
        settingsController = Helper.controllerFromStoryboard(controllerId: Constants.settingsControllerId)!
        
        carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
        
        if let selectedIndex = selectedIndex {
            carbonTabSwipeNavigation.setCurrentTabIndex(UInt(selectedIndex), withAnimation: true)
        }
        
        if FirstEntranceProvider.shared.currentStep == .profile && FirstEntranceProvider.shared.isFirstEntrancePassed == false {
            initBlockButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload data
        if detailsController != nil {
            detailsController.aboutController.reloadData()
        }
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction override func onBackButtonClicked(sender: UIBarButtonItem) {
        
        guard FirstEntranceProvider.shared.isProfileGuideCompleted else {
            
            if carbonTabSwipeNavigation.currentTabIndex == 1 {
                carbonTabSwipeNavigation.setCurrentTabIndex(0, withAnimation: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    // show force screen
                    self.profileController.hideHelpView(isHidden: false)
                }
            } else {
                
                if detailsController != nil { // we need to dismiss it
                    detailsController.onCloseButtonClicked(nil)
                } else {
                    
                    // show force screen
                    profileController.hideHelpView(isHidden: false)
                }
            }
            
            return
        }
        
        // move guide to "moment" screen if needs
        FirstEntranceProvider.shared.currentStep = .moments
        
        if let user = UserProvider.shared.currentUser, user.passionsIds.count != Configurations.General.requiredMinPassionsCount {
            
            // show dialog box
            let toManyPassionsView: NoCategoriesView = NoCategoriesView.loadFromNib()
            
            toManyPassionsView.topTextLabel.text = LocalizableString.SelectCategoriesAlert.localizedString
            toManyPassionsView.textLabel.text = LocalizableString.SelectCategoriesBottomTextAlert.localizedString
            
            toManyPassionsView.present(on: Helper.initialNavigationController().view)
            
            return
        }
        
        if let preferences = settingsController.preferences {
         
            showBlackLoader()
            
            PreferencesProvider.updatePreferences(preferences: preferences, completion: { (result) in
                switch(result) {
                    case .success(_):
                        self.hideLoader()
                        
                        if self.settingsController.isSearchLocationChanged {
                            
                            if Helper.currentTabBarItem() != 1 {
                                Helper.selectedTabBarItem(with: 1)
                            }
                        }
                        
                        super.onBackButtonClicked(sender: sender)
                    break
                case .failure(let error):
                    print("Error during saving preferences")
                    
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default:
                    break
                }
            })
        } else {
            super.onBackButtonClicked(sender: sender)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func initBlockButton() {
        
        blockButton = UIButton(type: .custom)
        blockButton?.backgroundColor = .clear
        blockButton?.addTarget(self, action: #selector(onBlockButtonClicked(sender:)), for: .touchUpInside)
        blockButton?.frame = CGRect(x: UIScreen.main.bounds.width / 2.0, y: 0, width: UIScreen.main.bounds.width / 2.0, height: Helper.carbonViewHeight())
        
        view.addSubview(blockButton!)
    }
    
    fileprivate func removeBlockButton() {
        
        if blockButton != nil {
            blockButton?.removeFromSuperview()
            blockButton = nil
        }
    }
    
    @objc fileprivate func onBlockButtonClicked(sender: UIButton) {
        
        if FirstEntranceProvider.shared.isFirstEntrancePassed == false && FirstEntranceProvider.shared.currentStep == .profile {
            profileController.hideHelpView(isHidden: false)
        }
    }
}

// MARK: - PersonalDetailsTabsViewControllerDelegate
extension PersonalTabsViewController: PersonalDetailsTabsViewControllerDelegate {
    
    func detailsControllerIsDismissed(_ controller: PersonalDetailsTabsViewController) {
        
        if !FirstEntranceProvider.shared.isAlreadyViewedSettings {
            
            // show settings
            carbonTabSwipeNavigation.setCurrentTabIndex(1, withAnimation: true)
        }
        
        detailsController = nil
    }
    
    func detailsControllerBeginToDismiss(_ controller: PersonalDetailsTabsViewController) {
        
    }
}

// MARK: - ProfileViewControllerDelegate
extension PersonalTabsViewController: ProfileViewControllerDelegate {
    
    func shouldShowDetails() {
        
        if detailsController == nil {
            detailsController = Helper.controllerFromStoryboard(controllerId: Constants.detailsControllerId)!
            detailsController.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height - profileController.bottomSpaceHeight), size: CGSize(width: view.frame.width, height: view.frame.height))
            detailsController.delegate = self
        }
        
        view.addSubview(detailsController.view)
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.detailsController.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        }) { (isFinished) in
            self.detailsController.didControllerChangedPosition(isOpened: true, completionHandler: nil)
            self.removeBlockButton()
        }
    }
    
    func showSettings() {
        
        carbonTabSwipeNavigation.setCurrentTabIndex(1, withAnimation: true)
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension PersonalTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, shouldMoveAt index: UInt) -> Bool {
        
//        if index == 1 && FirstEntranceProvider.shared.isFirstEntrancePassed == false && FirstEntranceProvider.shared.currentStep == .profile {
//            profileController.hideHelpView(isHidden: false)
//            return false
//        }
        return true
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return profileController
        } else {
            return settingsController
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        
        profileController.isSelected = index == 0
        settingsController.isSelected = index == 1
    }
}
