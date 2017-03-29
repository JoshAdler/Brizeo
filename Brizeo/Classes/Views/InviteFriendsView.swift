//
//  InviteFriendsView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import FBSDKShareKit
import SVProgressHUD

protocol InviteFriendsViewDelegate: class {
    func onInviteClicked(inviteView: InviteFriendsView)
    func onShareClicked(inviteView: InviteFriendsView)
}

class InviteFriendsView: UIView {
    
    // MARK: - Types
    
    struct Constants {
        static let animationDuration = 0.3
    }
    
    // MARK: - Properties
    
    weak var delegate: InviteFriendsViewDelegate?
    var chooseView: ChooseView?
    
    // background
    @IBOutlet weak var backgroundView: UIView!
    
    //views
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var notifyView: UIView!
    
    // buttons
    @IBOutlet weak var notifyButton: UIButton! {
        didSet {
            notifyButton.setTitle(LocalizableString.NotifyFriendsButtonTitle.localizedString, for: .normal)
        }
    }
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            shareButton.setTitle(LocalizableString.Share.localizedString, for: .normal)
        }
    }
    
    // labels
    @IBOutlet weak var notifyTopLabel: UILabel! {
        didSet {
            notifyTopLabel.text = LocalizableString.NotifyFriendsMainText.localizedString
        }
    }
    @IBOutlet weak var notifyDisclaimerLabel: UILabel! {
        didSet {
            notifyDisclaimerLabel.text = LocalizableString.NotifyFriendsDisclaimer.localizedString
        }
    }
    @IBOutlet weak var notifyDescriptionLabel: UILabel! {
        didSet {
            notifyDescriptionLabel.text = LocalizableString.NotifyFriendsInfo.localizedString
        }
    }
    @IBOutlet weak var shareTopLabel: UILabel! {
        didSet {
            shareTopLabel.text = LocalizableString.ShareTopText.localizedString
        }
    }
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shareView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        notifyView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        backgroundView.alpha = 0.0
    }
    
    // MARK: - Public methods
    
    func present(on view: UIView) {
        frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        view.addSubview(self)
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.shareView.transform = CGAffineTransform.identity
            self.notifyView.transform = CGAffineTransform.identity
            self.backgroundView.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCloseButtonClicked(sender: UIButton) {
        chooseView?.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    @IBAction func onShareButtonClicked(sender: UIButton) {
        chooseView = ChooseView.loadFromNib()
        chooseView?.present(on: superview!)
    }
    
    @IBAction func onNotifyButtonClicked(sender: UIButton) {
        // show loading
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        BranchProvider.generateInviteURL(forUserId: UserProvider.shared.currentUser!.objectId) { (url) in
            guard url != nil else {
                SVProgressHUD.showError(withStatus: LocalizableString.ErrorWithBranchURL.localizedString)
                return
            }
            
            let content = FBSDKAppInviteContent()
            content.appLinkURL = URL(string: url!)!
            content.promotionText = LocalizableString.FacebookInviteMessage.localizedString
            content.appInvitePreviewImageURL = URL(string: Configurations.Invite.previewURL)
            
            FBSDKAppInviteDialog.show(from: Helper.initialNavigationController(), with: content, delegate: self)
            
            LocalyticsProvider.trackInviteByFBDialog()
            
            // hide loading
            SVProgressHUD.dismiss()
        }
    }
}

// MARK: - FBSDKAppInviteDialogDelegate
extension InviteFriendsView: FBSDKAppInviteDialogDelegate {
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
    }
}
