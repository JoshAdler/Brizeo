//
//  PersonalTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit

class PersonalDetailsTabsViewController: BasicViewController {

    // MARK: - Types
    
    struct Constants {
        static let titles = [LocalizableString.About.localizedString, LocalizableString.Matches.localizedString, LocalizableString.MyMap.localizedString]
        static let aboutControllerId = "AboutViewController"
        static let matchesControllerId = "UserMatchesViewController"
        static let tripsControllerId = "TripsViewController"
    }
    
    // MARK: - Properties
    
    var aboutController: AboutViewController!
    var matchesController: UserMatchesViewController!
    var tripsController: TripsViewController!

    // MARK: - Properties
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = UserProvider.shared.currentUser else {
            assertionFailure("Error: No current user")
            return
        }
        
        // load controller
        aboutController = Helper.controllerFromStoryboard(controllerId: Constants.aboutControllerId)!
        aboutController.user = currentUser
        matchesController = Helper.controllerFromStoryboard(controllerId: Constants.matchesControllerId)!
        matchesController.user = currentUser
        tripsController = Helper.controllerFromStoryboard(controllerId: Constants.tripsControllerId)!
        tripsController.user = currentUser
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: targetView)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
    }

    // MARK: - Public methods
    
    func didControllerChangedPosition(isOpened: Bool, completionHandler: ((Void) -> Void)?) {
        
        if isOpened && FirstEntranceProvider.shared.isFirstEntrancePassed == false {
            FirstEntranceProvider.shared.currentStep = .moments
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            if isOpened {
                self.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                self.closeButton.transform = CGAffineTransform.identity
            }
        }) { (isFinished) in
            completionHandler?()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCloseButtonClicked(_ sender: UIButton) {
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height - self.topView.frame.height), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        }) { (isFinished) in
            self.didControllerChangedPosition(isOpened: false) {
                self.view.removeFromSuperview()
            }
        }
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension PersonalDetailsTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return aboutController
        } else if index == 1 {
            return matchesController
        } else {
            return tripsController
        }
    }
}



