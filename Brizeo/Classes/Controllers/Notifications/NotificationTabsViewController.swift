//
//  NotificationTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit
import SVProgressHUD

class NotificationTabsViewController: BasicViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let titles = [LocalizableString.LikesTitle.localizedString.capitalized, LocalizableString.People.localizedString.capitalized]
        static let notificationsControllerId = "NotificationsViewController"
    }
    
    // MARK: - Properties
    
    var likesController: NotificationsViewController!
    var peopleController: NotificationsViewController!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load controller
        likesController = Helper.controllerFromStoryboard(controllerId: Constants.notificationsControllerId)!
        likesController.contentType = .momentsLikes
        likesController.delegate = self
        
        peopleController = Helper.controllerFromStoryboard(controllerId: Constants.notificationsControllerId)!
        peopleController.delegate = self
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotifications(notification:)), name: NSNotification.Name(rawValue: shouldReloadNotifications), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        LocalyticsProvider.userViewNotifications()
    }
    
    // MARK: - Public methods
    
    func reloadNotifications(notification: NSNotification) {
        
        if let dict = notification.userInfo as? [String: Any], let type = dict["type"] as? NotificationType {
            if type == .momentsLikes && likesController.isViewLoaded {
                likesController.reloadContent()
            } else if type == .newMatches && peopleController.isViewLoaded {
                peopleController.reloadContent()
            }
        }
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension NotificationTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return likesController
        } else {
            return peopleController
        }
    }
}

// MARK: - NotificationsViewControllerDelegate
extension NotificationTabsViewController: NotificationsViewControllerDelegate {
    
    func loadNotifications(for type: NotificationType?, _ withLoading: Bool, completionHandler: @escaping ([Notification]?) -> Void) {
        
        if withLoading {
            showBlackLoader()
        }
        
        NotificationProvider.getNotification(for: UserProvider.shared.currentUser!.objectId) { (result) in
            
            if withLoading {
                self.hideLoader()
            }
            
            switch result {
            case .success(let notifications):
                
                if type == nil { // all matches types
                    let filteredNotifications = notifications.filter({ $0.pushType != NotificationType.momentsLikes }).sorted(by: { (leftNot, rightNot) -> Bool in
                        
                        let leftDate = leftNot.createDate
                        let rightDate = rightNot.createDate
                        
                        if leftDate == nil && rightDate == nil {
                            return true
                        } else if leftDate != nil && rightDate != nil {
                            return leftDate! > rightDate!
                        } else if leftDate != nil {
                            return true
                        } else {
                            return false
                        }
                    })
                    completionHandler(filteredNotifications)
                } else {
                    let filteredNotifications = notifications.filter({ $0.pushType == type }).sorted(by: { (leftNot, rightNot) -> Bool in
                        
                        let leftDate = leftNot.createDate
                        let rightDate = rightNot.createDate
                        
                        if leftDate == nil && rightDate == nil {
                            return true
                        } else if leftDate != nil && rightDate != nil {
                            return leftDate! > rightDate!
                        } else if leftDate != nil {
                            return true
                        } else {
                            return false
                        }
                    })
                    completionHandler(filteredNotifications)
                }
                
                let unreadNotifications = notifications.filter({ return !$0.isAlreadyViewed })
                
                Helper.sendNotification(with: notificationsBadgeNumberWasChanged, object: nil, dict: ["number": unreadNotifications.count])
                
            case .failure(let error):
                
                if withLoading {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                
                completionHandler(nil)
            default:
                break
            }
        }
    }
}
