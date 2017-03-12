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
        
        // notification for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
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
    
    // MARK: - Keyboard methods
    
    func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            scrollViewBottomConstraint.constant = Constants.bottomMargin + keyboardSize.height
            
//            UIView.animate(withDuration: 0.25, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
//        scrollViewBottomConstraint.constant = Constants.bottomMargin
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardDidHide(notification: NSNotification) {

    }
    
    // MARK: - Actions
    
    @IBAction func onCloseButtonClicked(_ sender: UIButton) {
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



