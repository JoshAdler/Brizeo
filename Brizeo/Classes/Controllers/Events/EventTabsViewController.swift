//
//  EventTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/26/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit

class EventTabsViewController: BasicViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let titles = [LocalizableString.All.localizedString.capitalized, LocalizableString.MyMatches.localizedString.capitalized]
        static let eventControllerId = "EventsViewController"
    }
    
    // MARK: - Properties
    
    var allEventsController: EventsViewController!
    var myMatchesController: EventsViewController!
    var isControllerReady = false
    var popupView: FirstEntranceEventsView?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        prepareController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        // update facebook events for current user
        EventsProvider.updateUserEventsIfNeeds()
        
        // show popup if needs
        if !FirstEntranceProvider.shared.isAlreadyViewedEvents {
            
            // load popup
            presentPopup()

            // mark first entrance for event screen
            FirstEntranceProvider.shared.isAlreadyViewedEvents = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // hide popup
        popupView?.hide()
    }
    
    // MARK: - Private methods
    
    fileprivate func presentPopup() {
        
        popupView = FirstEntranceEventsView.loadFromNib()
        popupView?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        AppDelegate.shared().window?.addSubview(popupView!)
    }
    
    fileprivate func prepareController() {
        // load controller
        allEventsController = Helper.controllerFromStoryboard(controllerId: Constants.eventControllerId)!
        allEventsController.parentController = self
        allEventsController.type = .all
        
        myMatchesController = Helper.controllerFromStoryboard(controllerId: Constants.eventControllerId)!
        myMatchesController.parentController = self
        myMatchesController.shouldHideLocation = true
        myMatchesController.type = .matches
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
        isControllerReady = true
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension EventTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return allEventsController
        } else {
            return myMatchesController
        }
    }
}
