//
//  LoginViewController.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/18/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD
import Branch

class LoginViewController: UIViewController {
    
    // MARK: - Types
    
    struct StoryboardIds {
        static let tabBarControllerId = "MainTabBarController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var termsSwitch: UISwitch!
    
    //MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = LocationManager.shared.requestCurrentLocation(nil)
        
        // check whether user is logged in
        if UserProvider.isUserLoggedInFacebook() {
            if UserProvider.shared.currentUser != nil {
                operateCurrentUser()
                
                // go next
                goNextToTabBar()
            } else {
                loadCurrentUser()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - Private methods
    
    fileprivate func goNextToTabBar() {
        let mainTabBarController = Helper.mainTabBarController()
        mainTabBarController.selectedIndex = 2 /* select "Moments" tab" */
        
        Helper.initialNavigationController().pushViewController(mainTabBarController, animated: true)
    }
    
    fileprivate func loadCurrentUser() {
        showBlackLoader()
        
        UserProvider.loadUser { (result) in
            switch result {
            case .success(_):
                self.operateCurrentUser()
                
                self.hideLoader()
                
                // go next
                self.goNextToTabBar()
                break
            case .failure(let error):
                if error.localizedDescription != APIError.notFound.localizedDescription {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                }
                break
            default:
                break
            }
        }
    }
    
    fileprivate func operateCurrentUser() {
        LocationManager.updateUserLocation()
        BranchProvider.checkUserReward()
        ChatProvider.registerUserInChat()
    }
    
    //MARK: - Actions
    
    @IBAction func loginWithFbButtonPressed(_ sender: AnyObject) {
        guard termsSwitch.isOn else {
            SVProgressHUD.showError(withStatus: "You have to accept our Terms of Use.")
            return
        }
    
        showBlackLoader()
        
        UserProvider.logInUser(with: LocationManager.shared.currentLocationCoordinates, from: self) { [unowned self] (result) in
            switch (result) {
            case .success(_):
                self.operateCurrentUser()
                self.hideLoader()
                
                self.goNextToTabBar()
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            case .userCancelled(_):
                SVProgressHUD.dismiss()
            }
        }
    }
    //TODO: check the place with loading
    
    @IBAction func termsButtonTapped(_ sender: UIButton) {
        let termsURL = URL(string: Configurations.General.termsOfUseURL)!
        Helper.openURL(url: termsURL)
    }
}
