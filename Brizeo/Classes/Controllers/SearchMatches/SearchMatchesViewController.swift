//
//  SeatchMatchesViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import DMSwipeCards
import MessageUI
import SVProgressHUD

class SearchMatchesViewController: BasicViewController {

    // MARK: - Types
    
    struct StoryboardIds {
        static let mediaControllerId = "MediaViewController"
        static let detailsControllerId = "OtherPersonDetailsTabsViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var swipeViewContainerView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var actionsButton: UIButton!
    
    var swipeView: DMSwipeCardsView<Any>!
    var matches: [User]?
    var currentUser: User! = UserProvider.shared.currentUser!
    var detailsController: OtherPersonDetailsTabsViewController!
    var mutualFriends: [(String, String)]?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        loadMatchesIfNeeds()
    }
    
    // MARK: - Private methods
    
    fileprivate func presentErrorAlert(message: String?) {
        let alert = UIAlertController(title: LocalizableString.Error.localizedString, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizableString.TryAgain.localizedString, style: .default, handler: { (action) in
            self.fetchMatchesList()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizableString.Dismiss.localizedString, style: .cancel, handler: { (action) in
            self.tabBarController?.selectedIndex = 2 /* go to moments */
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func fetchMatchesList() {
        setButtonsHidden(isHidden: true)
        showBlackLoader()
        
        MatchesProvider.getUsersForMatching(for: currentUser) { [weak self] (result) in
            if let welf = self {
                welf.hideLoader()
                
                switch result {
                case .failure(let error):
                    welf.presentErrorAlert(message: error.localizedDescription)
                    break
                case .success(let potentialMatches):
                    welf.matches = potentialMatches
                    welf.operateMatches()
                    break
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func setupSwipeViewIfNeeds() {
        // setup after we will have some cards
        if swipeView == nil {
            
            let viewGenerator = { (element: Any, frame: CGRect) -> (UIView) in
                let profileView: ProfileView = ProfileView.loadFromNib()
                
                profileView.frame = frame
                profileView.applyUser(user: element as! User)
                
                // passion
                if let passionId = (element as! User).topPassionId {
                    let passion = PassionsProvider.shared.getPassion(by: passionId)
                    profileView.setInterest(with: passion?.color, title: passion?.displayName, imageURL: passion?.iconURL)
                }
                
                return profileView
            }
            
            let overlayGenerator: (SwipeMode, CGRect) -> (UIView) = { (mode: SwipeMode, frame: CGRect) -> (UIView) in
                let imageView = UIImageView()
                imageView.image = mode == .left ? #imageLiteral(resourceName: "no") : #imageLiteral(resourceName: "ok")
                imageView.frame.size = CGSize(width: 100, height: 100)
                imageView.center = CGPoint(x: (mode == .left ? frame.width * (2.0 / 3.0): frame.width / 3.0), y: frame.height * 0.2)
                
                return imageView
            }
            
            let frame = swipeViewContainerView.frame
            swipeView = DMSwipeCardsView<Any>(frame: frame,
                                               viewGenerator: viewGenerator,
                                               overlayGenerator: overlayGenerator)
            swipeView.delegate = self
            view.addSubview(swipeView)
        }
    }
    
    fileprivate func operateMatches() {
        if let matches = matches {
            if matches.count == 0 { // no matches for review
                
                // show confirmation
                let confirmationView: NoMatchesView = NoMatchesView.loadFromNib()
                confirmationView.present(on: Helper.initialNavigationController().view, confirmAction: {
                    
                    let personalController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.personalTabsController)!
                    personalController.selectedIndex = 1
                    self.navigationController?.pushViewController(personalController, animated: true)
                }, declineAction: {
                    self.tabBarController?.selectedIndex = 2 /* go to moments */
                })
                
                return
            }
            
            setupSwipeViewIfNeeds()
            swipeView.addCards(matches)
            
            setButtonsHidden(isHidden: false)
        } else {
            print("No matches")
        }
    }
    
    fileprivate func setButtonsHidden(isHidden: Bool) {
        detailsButton.isHidden = isHidden
        actionsButton.isHidden = isHidden
        shareButton.isHidden = isHidden
    }
    
    fileprivate func loadMatchesIfNeeds() {
        if matches == nil || matches?.count == 0 {
            fetchMatchesList()
        }
    }
    
    fileprivate func declineUser(user: User) {
        showBlackLoader()
        
        MatchesProvider.declineMatch(for: user) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    if (welf.matches?.count ?? 0) > 0 {
                        welf.matches?.removeFirst()
                    }
                    
                    welf.hideLoader()
                    welf.loadMatchesIfNeeds()
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    
                    if (welf.matches?.count ?? 0) > 0 {
                        welf.matches?.removeFirst()
                    }
                    
                    break
                default: break
                }
            }
        }
    }
    
    fileprivate func approveUser(user: User) {
        showBlackLoader()
        
        MatchesProvider.approveMatch(for: user) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    if (welf.matches?.count ?? 0) > 0 {
                        welf.matches?.removeFirst()
                    }
                    
                    if user.status == .isMatched {
                        Helper.showMatchingCard(with: user, from: welf.navigationController!)
                    } else {
                        welf.loadMatchesIfNeeds()
                    }
                    welf.hideLoader()
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    
                    if (welf.matches?.count ?? 0) > 0 {
                        welf.matches?.removeFirst()
                    }
                    
                    break
                default: break
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onDetailButtonClicked(sender: UIButton) {
        guard matches != nil else {
            assertionFailure("Can't get details for nobody")
            return
        }
        // TODO: check whether we need to get first or last from the array of matches]
        if detailsController == nil {
            detailsController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.detailsControllerId)!
            detailsController.user = matches!.first
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
    
    @IBAction func onShareButtonClicked(sender: UIButton) {
        guard matches != nil, let user = matches?.first else {
            print("No user for sharing")
            return
        }
        
        BranchProvider.generateInviteURL(forUserId: user.objectId, imageURL: user.profileUrl?.absoluteString) { (url) in
            if let url = url {
                let modifiedURL = "\(LocalizableString.SharePersonMessage.localizedString) \n\n \(url)"
                
                if MFMessageComposeViewController.canSendText() {
                    let messageComposeVC = MFMessageComposeViewController()
                    messageComposeVC.body = modifiedURL
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
    
    @IBAction func onActionButtonClicked(sender: UIButton) {
        guard matches != nil else {
            print("Can't report anyone")
            return
        }
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: LocalizableString.Report.localizedString, style: .default, handler: { alert in
            self.showBlackLoader()
            UserProvider.report(user: self.matches!.first!, completion: { (result) in
                self.hideLoader()
                switch result {
                    
                case .success(_):
                    self.showAlert("", message: LocalizableString.UserHadBeenReported.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    self.actionsButton.isHidden = true
                    break
                case .failure(let error):
                    self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                default:
                    break
                }
            })
        })
        
        alertVC.addAction(reportAction)
        let cancelAction = UIAlertAction(title: LocalizableString.Cancel.localizedString, style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - DMSwipeCardsViewDelegate
extension SearchMatchesViewController: DMSwipeCardsViewDelegate {
    
    func swipedLeft(_ object: Any) {
        print("left")
        
        declineUser(user: object as! User)
    }
    
    func swipedRight(_ object: Any) {
        print("right")
        
        approveUser(user: object as! User)
    }
    
    func cardTapped(_ object: Any) {
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
//        mediaController.isSharingEnabled = true
        mediaController.media = (object as! User).allMedia
        
        navigationController?.pushViewController(mediaController, animated: true)
    }
    
    func reachedEndOfStack() {
        //clear old data
        matches?.removeAll()
        
        // fetch new data
        fetchMatchesList()
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension SearchMatchesViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
