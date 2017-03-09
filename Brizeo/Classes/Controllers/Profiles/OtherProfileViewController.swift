//
//  OtherProfileViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import MessageUI
import SVProgressHUD
import SDWebImage

class OtherProfileViewController: BasicViewController {

    // MARK: - Types
    
    struct Constants {
        static let profileFullSizeCoef: CGFloat = 1065/1204
    }
    
    struct StoryboardIds {
        static let detailsControllerId = "OtherPersonDetailsTabsViewController"
        static let mediaControllerId = "MediaViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var interestView: OtherPersonInterestView!
    @IBOutlet weak var profileViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileView: UIView! {
        didSet {
            profileView.layer.cornerRadius = 10.0
            profileView.layer.borderWidth = 1.0
            profileView.layer.borderColor = HexColor("f6f6f6")?.cgColor
        }
    }
    
    var user: User!
    var mutualFriends: [(String, String)]?
    var passions: [Passion]?
    var detailsController: OtherPersonDetailsTabsViewController!
    
    // MARK: - Controller lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMutualFriends()
        fetchPassions()
        applyUserData()
        
        loadStatusBetweenUsers()
        
        //add mutual friends observer
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedMutualFriendsNotification(notification:)), name: NSNotification.Name(rawValue: mutualFriendsNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    fileprivate func applyUserData() {
        nameLabel.text = "\(user.displayName), \(user.age)"
        studyLabel.text = user.studyInfo
        workLabel.text = user.workInfo
        
        if user.hasProfileImage {
            profileImageView.sd_setImage(with: user.profileUrl!)
        }
        
        if let mutualFriends = mutualFriends {
            friendsCountLabel.text = "\(mutualFriends.count)"
        }
    }
    
    fileprivate func fetchMutualFriends() {
        let currentUser = UserProvider.shared.currentUser!
        UserProvider.getMutualFriendsOfCurrentUser(currentUser, andSecondUser: user, completion: { (result) in
            switch result {
            case .success(let value):
                self.mutualFriends = value
                self.friendsCountLabel.text = "\(value.count)"
            case .failure(let error):
                self.friendsCountLabel.text = "0"
                self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
            default:
                break
            }
        })
    }
    
    fileprivate func fetchPassions() {
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            
            if let weak = self {
                switch result {
                case .success(let passions):
                    weak.passions = passions
                    
                    // try to get top passion
                    if let topPassionId = weak.user.topPassionId, let userPassion = weak.passions?.filter({ topPassionId == $0.objectId! }).first {
                        
                        if let iconLink = userPassion.iconLink {
                            weak.interestView.interestImageView.sd_setImage(with: iconLink)
                        }
                        
                        weak.interestView.title = userPassion.displayName
                        weak.interestView.interestColor = userPassion.color
                    }
                    else { // set default passion "Travel"
                        if let defaultPassion = weak.passions?.filter({ $0.displayName == "Travel" }).first {
                        
                            if let iconLink = defaultPassion.iconLink {
                                weak.interestView.interestImageView.sd_setImage(with: iconLink)
                            }
                            
                            weak.interestView.title = defaultPassion.displayName
                            weak.interestView.interestColor = defaultPassion.color
                        } else {
                            weak.interestView.isHidden = true
                        }
                    }
                    break
                case .failure(let error):
                    weak.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
                    break
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func increaseProfileViewHeight(_ animated: Bool) {
        let newConstraint = profileViewHeightConstraint.constraintWithMultiplier(multiplier: Constants.profileFullSizeCoef)
        view!.removeConstraint(profileViewHeightConstraint)
        view!.addConstraint(newConstraint)
        profileViewHeightConstraint = newConstraint
        
        if animated {            
            UIView.animate(withDuration: 0.5, animations: { 
                self.view!.layoutIfNeeded()
                self.approveButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.declineButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            }, completion: { (isFinished) in
                if isFinished {
                    self.approveButton.isHidden = true
                    self.declineButton.isHidden = true
                }
            })
        } else {
            approveButton.isHidden = true
            declineButton.isHidden = true
            self.view!.layoutIfNeeded()
        }
    }
    
    fileprivate func loadStatusBetweenUsers() {
        showBlackLoader()
        
        UserProvider.getUserWithStatus(for: user.objectId) { [weak self] (result) in
            if let welf = self {
                
                welf.hideLoader()
                
                switch(result) {
                case .success(let user):
                    
                    // check whether the user has been already matched
                    if false {
                        welf.increaseProfileViewHeight(false)
                    }
                    
                    break
                case .failure(let error):
                    break
                default: break
                }
            }
        }
    }
    
    fileprivate func declineUser() {
        showBlackLoader()
        
        MatchesProvider.declineMatch(for: user) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    welf.increaseProfileViewHeight(true)
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    
    fileprivate func approveUser() {
        showBlackLoader()
        
        MatchesProvider.approveMatch(for: user) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    welf.increaseProfileViewHeight(true)
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    //TODO: check text cell for many text
    // MARK: - Public methods

    func didReceivedMutualFriendsNotification(notification: UIKit.Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            let friends = userInfo["mutualFriends"] as? [(String, String)]
            let userId = userInfo["userId"] as? String? ?? "-1"
            
            if userId == user.objectId {
                self.mutualFriends = friends
                self.friendsCountLabel.text = "\(mutualFriends?.count ?? 0)"
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onProfilePictureButtonClicked(sender: UIButton) {
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.media = user.allMedia
        
        Helper.initialNavigationController().pushViewController(mediaController, animated: true)
    }
    
    @IBAction func onDeclineButtonClicked(_ sender: UIButton) {
        increaseProfileViewHeight(true)
        
        declineUser()
    }
    
    @IBAction func onAcceptButtonClicked(_ sender: UIButton) {
        increaseProfileViewHeight(true)
        
        approveUser()
    }
    
    @IBAction func onShareButtonClicked(_ sender: UIButton) {
        BranchProvider.generateInviteURL(forUserId: user.objectId) { (url) in
            if let url = url {
                if MFMessageComposeViewController.canSendText() {
                    let messageComposeVC = MFMessageComposeViewController()
                    messageComposeVC.body = url
                    messageComposeVC.delegate = self
                    messageComposeVC.messageComposeDelegate = self
                    messageComposeVC.recipients = nil
                    self.present(messageComposeVC, animated: true, completion: nil)
                } else {
                    SVProgressHUD.showError(withStatus: LocalizableString.ShareSmsFails.localizedString)
                }
            }
        }
    }
    
    @IBAction func onMoreButtonClicked(_ sender: UIButton) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
            self.showBlackLoader()
            
            UserProvider.report(user: self.user, completion: { (result) in
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
    
    @IBAction func onDetailsButtonClicked(_ sender: UIButton) {
        if detailsController == nil {
            detailsController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.detailsControllerId)!
            detailsController.user = user
            detailsController.mutualFriends = mutualFriends
            
            detailsController.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height), size: CGSize(width: view.frame.width, height: view.frame.height))
            detailsController.view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        
        view.addSubview(detailsController.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.detailsController.view.transform = CGAffineTransform.identity
            self.detailsController.view.frame = CGRect(origin: CGPoint.zero, size: self.view.frame.size)
        }) { (isFinished) in
            self.detailsController.didControllerChangedPosition(completionHandler: nil)
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension OtherProfileViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
