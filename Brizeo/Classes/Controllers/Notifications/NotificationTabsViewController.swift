//
//  NotificationTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit

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
        likesController.contentType = .likes
        peopleController = Helper.controllerFromStoryboard(controllerId: Constants.notificationsControllerId)!
        peopleController.contentType = .people
        
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
