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
        static let profileFullSizeCoef: CGFloat = 60
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
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileView: UIView! {
        didSet {
            profileView.layer.cornerRadius = 10.0
            profileView.layer.borderWidth = 1.0
            profileView.layer.borderColor = HexColor("f6f6f6")?.cgColor
        }
    }
    
    var user: User?
    var userId: String?
    var mutualFriends: [User]?
    var passions: [Passion]?
    var detailsController: OtherPersonDetailsTabsViewController!
    
    // MARK: - Controller lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserIfNeeds()
        
        //add mutual friends observer
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedMutualFriendsNotification(notification:)), name: NSNotification.Name(rawValue: mutualFriendsNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    fileprivate func loadUserIfNeeds() {
        loadStatusBetweenUsers { [weak self] in
            
            if let welf = self {
                
                // hide/show action buttons
                if !welf.user!.shouldBeAction {
                    welf.decreaseProfileViewHeight(true)
                }
                
                welf.fetchMutualFriends()
                welf.fetchPassions()
                
                welf.applyUserData()
            }
        }
    }
    
    fileprivate func presentErrorAlert(message: String?) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            self.loadUserIfNeeds()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func applyUserData() {
        guard let user = user else {
            return
        }
        
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
        
        guard let user = user else {
            return
        }
        
        UserProvider.getMutualFriends(for: user) { (result) in
            switch result {
            case .success(let count, let users):
                
                self.mutualFriends = users
                self.friendsCountLabel.text = "\(count)"
            case .failure(let error):
                
                self.friendsCountLabel.text = "0"
                //self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
            default:
                break
            }
        }
    }
    
    fileprivate func fetchPassions() {
        guard user != nil else {
            return
        }
        
        PassionsProvider.shared.retrieveAllPassions(true) { [weak self] (result) in
            
            if let weak = self {
                switch result {
                case .success(let passions):
                    weak.passions = passions
                    //TODO: add delete button to matches
                    // try to get top passion
                    if let topPassionId = weak.user!.topPassionId, let userPassion = weak.passions?.filter({ topPassionId == $0.objectId! }).first {
                        
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
    
    fileprivate func decreaseProfileViewHeight(_ animated: Bool) {
        bottomViewHeightConstraint.constant = Constants.profileFullSizeCoef
        
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
    
    fileprivate func loadStatusBetweenUsers(completion: @escaping (Void) -> Void) {
        showBlackLoader()
        
        guard let userIdentifier = userId ?? user?.objectId else {
            print("Can't load user without id")
            hideLoader()
            return
        }
        
        UserProvider.getUserWithStatus(for: userIdentifier) { [weak self] (result) in
            if let welf = self {
                
                welf.hideLoader()
                
                switch(result) {
                case .success(let user):
                    
                    welf.user = user
                    completion()
                    break
                case .failure(let error):
                    
                    welf.presentErrorAlert(message: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    
    fileprivate func declineUser() {
        showBlackLoader()
        
        MatchesProvider.declineMatch(for: user!) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    welf.decreaseProfileViewHeight(true)
                    
                    LocalyticsProvider.trackUserDidDeclined()
                    
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
        
        MatchesProvider.approveMatch(for: user!) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    welf.decreaseProfileViewHeight(true)
                    
                    LocalyticsProvider.trackUserDidApproved()
                    
                    if welf.user!.status == .isMatched {
                        Helper.showMatchingCard(with: welf.user!, from: welf.navigationController!)
                    }
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    
    // MARK: - Public methods

    func didReceivedMutualFriendsNotification(notification: UIKit.Notification) {
        guard user != nil else {
            return
        }
        
        if let userInfo = notification.userInfo as? [String: Any] {
            let friends = userInfo["mutualFriends"] as? [User]
            let userId = userInfo["userId"] as? String? ?? "-1"
            let count = userInfo["count"] as? Int ?? 0
            
            if userId == user!.objectId {
                self.mutualFriends = friends
                self.friendsCountLabel.text = "\(count)"
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onProfilePictureButtonClicked(sender: UIButton) {
        guard user != nil else {
            return
        }
        
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.media = user!.allMedia
        
        navigationController?.pushViewController(mediaController, animated: true)
    }
    
    @IBAction func onDeclineButtonClicked(_ sender: UIButton) {
        declineUser()
    }
    
    @IBAction func onAcceptButtonClicked(_ sender: UIButton) {
        approveUser()
    }
    
    @IBAction func onShareButtonClicked(_ sender: UIButton) {
        guard user != nil else {
            return
        }
        
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
    
    @IBAction func onMoreButtonClicked(_ sender: UIButton) {
        guard user != nil else {
            return
        }
        
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
    
    @IBAction func onDetailsButtonClicked(_ sender: UIButton) {
        
        if detailsController == nil {
            detailsController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.detailsControllerId)!
            detailsController.user = user
            // TODO:
            detailsController.mutualFriends = mutualFriends
            
            detailsController.view.frame = CGRect(origin: CGPoint(x: 0, y: view.frame.height), size: CGSize(width: view.frame.width, height: view.frame.height - ThemeManager.tabbarHeight()))
            detailsController.view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        
        view.addSubview(detailsController.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.detailsController.view.transform = CGAffineTransform.identity
            self.detailsController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - ThemeManager.tabbarHeight()))
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
