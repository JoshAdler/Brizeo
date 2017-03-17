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
        peopleController.contentType = .newMatches
        peopleController.delegate = self
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.mainTabBarController()?.tabBar.isHidden = false
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
    
    func loadNotifications(for type: NotificationType, completionHandler: @escaping ([Notification]?) -> Void) {
        showBlackLoader()
        
        NotificationProvider.getNotification(for: UserProvider.shared.currentUser!.objectId) { (result) in
            self.hideLoader()
            
            switch result {
            case .success(let notifications):
                let filteredNotifications = notifications.filter({ $0.pushType == type })
                completionHandler(filteredNotifications)
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                completionHandler(nil)
            default:
                break
            }
        }
    }
}
