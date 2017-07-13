//
//  OtherPersonTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit
import MessageUI
import SVProgressHUD

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
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
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
    
    @IBAction func onMoreButtonClicked(_ sender: Any) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
            self.showBlackLoader()
            
            UserProvider.report(user: self.user!, completion: { (result) in
                self.hideLoader()
                
                switch result {
                case .success(_):
                    self.showAlert("", message: LocalizableString.UserHadBeenReported.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    self.actionsButton.isHidden = true
                    break
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                default: break
                }
            })
        }))
        
        alertVC.addAction(UIAlertAction(title: LocalizableString.Cancel.localizedString, style: .cancel, handler: nil))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func onShareButtonClicked(_ sender: Any) {
        BranchProvider.generateInviteURL(forUserId: user!.objectId, imageURL: user!.profileUrl?.absoluteString) { (url) in
            if let url = url {
                let modifiedURL = "\(LocalizableString.SharePersonMessage.localizedString) \n\n \(url)"
                
                if MFMessageComposeViewController.canSendText() {
                    let messageComposeVC = MFMessageComposeViewController()
                    messageComposeVC.body = modifiedURL
                    messageComposeVC.delegate = self
                    messageComposeVC.messageComposeDelegate = self
                    messageComposeVC.recipients = nil
                    self.present(messageComposeVC, animated: true, completion: nil)
                    
                    LocalyticsProvider.trackInviteByPicture()
                    
                } else {
                    SVProgressHUD.showError(withStatus: LocalizableString.ShareSmsFails.localizedString)
                }
            }
        }
    }
    
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

// MARK: - MFMessageComposeViewControllerDelegate
extension OtherPersonDetailsTabsViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
