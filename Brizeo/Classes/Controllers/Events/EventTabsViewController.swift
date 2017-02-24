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
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        prepareController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isControllerReady && UserProvider.isAlreadyLoggedIn() {
            prepareController()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Private methods
    
    fileprivate func prepareController() {
        // load controller
        allEventsController = Helper.controllerFromStoryboard(controllerId: Constants.eventControllerId)!
        myMatchesController = Helper.controllerFromStoryboard(controllerId: Constants.eventControllerId)!
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
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
