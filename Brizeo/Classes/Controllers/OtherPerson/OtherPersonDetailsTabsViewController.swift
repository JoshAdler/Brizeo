//
//  OtherPersonTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit

class OtherPersonDetailsTabsViewController: BasicViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let titles = [LocalizableString.About.localizedString.capitalized, LocalizableString.Moments.localizedString.capitalized, LocalizableString.Map.localizedString.capitalized]
        static let aboutControllerId = "OtherPersonAboutViewController"
        static let momentsControllerId = "MomentsViewController"
        static let tripsControllerId = "TripsViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var aboutController: OtherPersonAboutViewController!
    var momentsController: MomentsViewController!
    var tripsController: TripsViewController!
    var user: User!
    var mutualFriends: [User]?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load controller
        aboutController = Helper.controllerFromStoryboard(controllerId: Constants.aboutControllerId)!
        aboutController.user = user
        aboutController.mutualFriends = mutualFriends
        
        momentsController = Helper.controllerFromStoryboard(controllerId: Constants.momentsControllerId)!
        momentsController.listType = .myMoments(userId: user.objectId)
        momentsController.shouldHideFilterView = true
        
        tripsController = Helper.controllerFromStoryboard(controllerId: Constants.tripsControllerId)!
        tripsController.user = user
        
        let carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: containerView)
    }
    
    // MARK: - Public methods
    
    func didControllerChangedPosition(completionHandler: ((Void) -> Void)?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }) { (isFinished) in
            completionHandler?()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCloseButtonClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height).scaledBy(x: 0.0001, y: 0.0001)
        }) { (isFinished) in
            self.closeButton.transform = CGAffineTransform.identity
            self.view.removeFromSuperview()
        }
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension OtherPersonDetailsTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return aboutController
        } else if index == 1 {
            return momentsController
        } else {
            return tripsController
        }
    }
}
