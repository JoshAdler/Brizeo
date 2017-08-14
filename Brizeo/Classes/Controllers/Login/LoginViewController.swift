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
import Firebase

let messagesBadgeNumberWasChanged = "messagesBadgeNumberWasChanged"

class LoginViewController: UIViewController {
    
    // MARK: - Types
    
    struct StoryboardIds {
        static let tabBarControllerId = "MainTabBarController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var termsSwitch: UISwitch! {
        didSet {
            termsSwitch.transform = CGAffineTransform(scaleX: 0.816, y: 0.69)
        }
    }
    
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
                loadCurrentUser(failureCompletion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: - Private methods
    
    fileprivate func goNextToTabBar() {
        let mainTabBarController = Helper.createMainTabBarController()
        mainTabBarController.selectedIndex = 2 /* select "Moments" tab" */
        
        Helper.initialNavigationController().pushViewController(mainTabBarController, animated: true)
    }
    
    fileprivate func loadCurrentUser(failureCompletion: ((Void) -> Void)?) {
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
                    if failureCompletion == nil {
                        SVProgressHUD.dismiss()
                    }
                    failureCompletion?()
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
        
        // save token for push notifications
        NotificationProvider.updateCurrentUserToken()
        
        // update facebook events for current user
        EventsProvider.updateUserEventsIfNeeds()
        
        // track statistics
        LocalyticsProvider.trackCurrentUser()
        
        // fetch initial data to cache
        PassionsProvider.shared.retrieveAllPassions(false, type: .normal, nil)
        PassionsProvider.shared.retrieveAllPassions(false, type: .extended, nil)
        
        // run timer to reset action counter
        ActionCounter.runResetTimer()
        
        // load notifications to set badge number
        loadNotifications()
        
        // load number of unread messages
        let unreadMessagesNumber = ChatProvider.totalUnreadCount()
        Helper.sendNotification(with: messagesBadgeNumberWasChanged, object: nil, dict: ["number": unreadMessagesNumber])
    }
    
    fileprivate func loadNotifications() {
        
        NotificationProvider.getNotification(for: UserProvider.shared.currentUser!.objectId) { (result) in
            
            switch result {
            case .success(let notifications):
                
                let unreadNotifications = notifications.filter({ return !$0.isAlreadyViewed })
                let likesNotifications = unreadNotifications.filter({ $0.pushType == .momentsLikes })
                                
                Helper.sendNotification(with: notificationsBadgeNumberWasChanged, object: nil, dict: [
                    "number": unreadNotifications.count,
                    "likesNumber": likesNotifications.count,
                    "peopleNumber": unreadNotifications.count - likesNotifications.count
                    ])
            case .failure(let error):
                print("Failure with getting notifications: \(error.localizedDescription)")
            default:
                break
            }
        }
    }
    
    fileprivate func signUpWithFacebook() {
        
        hideLoader()
        
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
    
    //MARK: - Actions
    
    @IBAction func loginWithFbButtonPressed(_ sender: AnyObject) {
        guard termsSwitch.isOn else {
            SVProgressHUD.showError(withStatus: "You have to accept our Terms of Use.")
            return
        }
    
        showBlackLoader()
        
        // check whether user is logged in
        if UserProvider.isUserLoggedInFacebook() {
            loadCurrentUser(failureCompletion: {
                self.signUpWithFacebook()
            })
        } else {
            signUpWithFacebook()
        }
    }
    
    @IBAction func termsButtonTapped(_ sender: UIButton) {
        let termsURL = URL(string: Configurations.General.termsOfUseURL)!
        Helper.openURL(url: termsURL)
    }
}
