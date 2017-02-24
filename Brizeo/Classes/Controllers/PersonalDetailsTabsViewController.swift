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
        
        let user = User.test()
        
        // load controller
        aboutController = Helper.controllerFromStoryboard(controllerId: Constants.aboutControllerId)!
        aboutController.user = user
        matchesController = Helper.controllerFromStoryboard(controllerId: Constants.matchesControllerId)!
        matchesController.user = user
        tripsController = Helper.controllerFromStoryboard(controllerId: Constants.tripsControllerId)!
        tripsController.user = user
        
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
    
    func keyboardWillShow(notification: Notification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            scrollViewBottomConstraint.constant = Constants.bottomMargin + keyboardSize.height
            
//            UIView.animate(withDuration: 0.25, animations: {
//                self.view.layoutIfNeeded()
//            })
//        }
    }
    
    func keyboardDidShow(notification: Notification) {
    }
    
    func keyboardWillHide(notification: Notification) {
//        scrollViewBottomConstraint.constant = Constants.bottomMargin
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardDidHide(notification: Notification) {

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



