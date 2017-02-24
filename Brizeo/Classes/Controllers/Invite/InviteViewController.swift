//
//  InviteViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/28/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Branch
import Crashlytics
import Parse
import FBSDKShareKit
import FBSDKMessengerShareKit
import MessageUI
import Social

class InviteViewController: BasicViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var invitedFriendsCountLabel: UILabel!
    @IBOutlet weak var invitedFriendsTextLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inviteFacebookButton: UIButton!
    @IBOutlet weak var inviteContactsButton: UIButton!
    @IBOutlet weak var inviteFriendsLabel: UILabel!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var rewardsButton: UIButton?
    @IBOutlet weak var bottomTextLabel: UILabel!

    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCount()
    }
    
    // MARK: - Override methods
    
    override func shouldPlaceInviteButton() -> Bool {
        return false
    }

    // MARK: - Public methods
    
    func setupUI() {
        invitedFriendsTextLabel.text = LocalizableString.FriendsSuccessfullyInvited.localizedString
        inviteFriendsLabel.text = LocalizableString.InviteFriendsByEmail.localizedString
        bottomTextLabel.text = LocalizableString.BrizeoShareJoinCommunity.localizedString
        
        inviteFacebookButton.setTitle(LocalizableString.InviteFriendsFromFacebook.localizedString, for: UIControlState())
        inviteContactsButton.setTitle(LocalizableString.ShareWithFriends.localizedString, for: UIControlState())
        sendButton.setTitle(LocalizableString.Send.localizedString, for: UIControlState())
        rewardsButton?.setTitle(LocalizableString.SeeRewardsForInvitingYourFriends.localizedString, for: UIControlState())
        
        addDismissKeyboardGestureRecognizer()
        resizeViewWhenKeyboardAppears = true
        emailTextView.text = LocalizableString.BrizeoShareDescription.localizedString
    }
    
    func getCount(){
        Branch.currentInstance.loadRewards { (changed, error) -> Void in
            let bucket = BranchKeys.ReferralBucket
            let credits = Branch.currentInstance.getCreditsForBucket(bucket)
            self.invitedFriendsCountLabel.text = "\(credits)"
        }
    }
    
    // MARK: Actions
    
    @IBAction func onFacebookButtonClicked(_ sender: UIButton) {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.BrizeoShareWithFacebook.localizedString
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = BranchKeys.FeatureInvite
        linkProperties.channel = BranchKeys.ChannelFacebook
        branchUniversalObject.addMetadataKey(BranchKeys.IdentifierReferrer, value: (User.current()?.objectId)!)
        
        branchUniversalObject.getShortUrl(with: linkProperties,  andCallback: { (url, error) -> Void in
            if error == nil {
                CLSNSLogv("Branch Returned successfully with link", getVaList([]))
                
                let content = FBSDKShareLinkContent()
                content.contentURL = URL(string: url!)
                content.imageURL = URL(string:BrizeoImage.BrizeoLogoImage.rawValue)
                
                content.contentTitle = LocalizableString.TryBrizeo.localizedStringWithArguments([(User.current()?.displayName)!])
                content.contentDescription = LocalizableString.BrizeoShareWithFacebook.localizedString
                FBSDKShareDialog.show(from: self, with: content, delegate: self)
            } else {
                CLSNSLogv("ERROR: Branch returned error: %@", getVaList([error! as CVarArg]))
            }
        })
        GoogleAnalyticsManager.userShareWithFacebook.sendEvent()
    }
    // TODO: check whether there is a crash here like on the device
    @IBAction func onContactsButtonClicked(_ sender: UIButton) {
        
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.InviteFriends.localizedString
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = BranchKeys.FeatureInvite
        linkProperties.channel = BranchKeys.ChannelSocial
        
        branchUniversalObject.getShortUrl(with: linkProperties,  andCallback: { (url, error) -> Void in
            if error == nil {
                
                let image = BrizeoImage.BrizeoPromo.image
                let modifiedURLString = LocalizableString.TryBrizeo.localizedStringWithArguments([(User.current()?.displayName)!]) + "\n\n" + LocalizableString.BrizeoShareDescription.localizedString+" "+LocalizableString.CheckItOutAt.localizedStringWithArguments([url!])
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { (action) in
                    if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                        vc.setInitialText(modifiedURLString)
                        vc.add(image)
                        vc.add(URL(string: url!))
                        self.present(vc, animated: true, completion: nil)
                    }
                })
                
                twitterAction.setValue(UIImage(named: "twitter-icon"), forKey: "image")
                
                let messengerAction = UIAlertAction(title: "Messenger", style: .default, handler: { (action) in
                    let content = FBSDKShareLinkContent()
                    content.contentURL = URL(string: url!)
                    content.imageURL = URL(string:BrizeoImage.BrizeoLogoImage.rawValue)
                    
                    content.contentTitle = LocalizableString.TryBrizeo.localizedStringWithArguments([(User.current()?.displayName)!])
                    content.contentDescription = LocalizableString.BrizeoShareDescription.localizedString
                    FBSDKMessageDialog.show(with: content, delegate:self)
                })
                
                messengerAction.setValue(UIImage(named: "Facebook-icon-1"), forKey: "image")
                
                let whatsAppAction = UIAlertAction(title: "WhatsApp", style: .default, handler: { (action) in
                    let originalString = modifiedURLString
                    let encodedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    let url = URL(string: "whatsapp://send?text="+encodedString!)
                    
                    if UIApplication.shared.canOpenURL(url!) {
                        
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url!)
                        }
                        
                    } else {
                        
                        print("whatsapp not installed")
                    }
                })
                
                whatsAppAction.setValue(UIImage(named: "whatsapp-plus"), forKey: "image")
                
                let SMSMessage = UIAlertAction(title: "SMS Message", style: .default, handler: { (action) in
                    if MFMessageComposeViewController.canSendText() {
                        let messageComposeVC = MFMessageComposeViewController()
                        messageComposeVC.body = modifiedURLString
                        messageComposeVC.delegate = self
                        messageComposeVC.messageComposeDelegate = self
                        messageComposeVC.recipients = nil
                        self.present(messageComposeVC, animated: true, completion: nil)
                    }
                })
                
                SMSMessage.setValue(UIImage(named: "chatbubble-icon"), forKey: "image")
                
                let mailAction = UIAlertAction(title: "E-Mail", style: .default, handler: { (action) in
                    let st = self.emailTextView.text
                    let mailComposerVC = MFMailComposeViewController()
                    let modifiedURLString = NSString(format: LocalizableString.BrizeoMailDescription.rawValue as NSString, st!)
                    let modifiedString = NSString(format: LocalizableString.CheckItOutHere.rawValue as NSString, url!, url!)
                    let modifiedSubString = NSString(format: "%@%@", modifiedURLString, modifiedString)
                    let width = self.view.frame.size.width
                    let mailContent = NSString(format: LocalizableString.BrizeoMailContent.rawValue as NSString, width, width * 0.9, (User.current()?.displayName)!, modifiedSubString)
                    mailComposerVC.mailComposeDelegate = self
                    mailComposerVC.setSubject(LocalizableString.TryBrizeo.localizedStringWithArguments([(User.current()?.displayName)!]))
                    mailComposerVC.setMessageBody(mailContent as String, isHTML: true)
                    if MFMailComposeViewController.canSendMail() {
                        
                        self.present(mailComposerVC, animated: true, completion: nil)
                    } else {
                        self.showAlert(LocalizableString.CouldNotSendEmail.localizedString, message: LocalizableString.PleaseTryAgain.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                    }
                })
                
                mailAction.setValue(UIImage(named: "email-icon"), forKey: "image")
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                })
                
                alertController.addAction(SMSMessage)
                alertController.addAction(messengerAction)
                alertController.addAction(whatsAppAction)
                alertController.addAction(mailAction)
                alertController.addAction(twitterAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
        GoogleAnalyticsManager.userShareWithNativeShare.sendEvent()
    }
    
    @IBAction func onSendButtonClicked(_ sender: UIButton) {
        let st = emailTextView.text
        let fullNameArr = st?.components(separatedBy: ",")
        let mailComposerVC = MFMailComposeViewController()
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
        
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.InviteFriends.localizedString
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = BranchKeys.FeatureInvite
        linkProperties.channel = BranchKeys.ChannelMail
        branchUniversalObject.addMetadataKey((User.current()?.objectId)!, value: BranchKeys.IdentifierReferrer)
        branchUniversalObject.getShortUrl(with: linkProperties,  andCallback: { (url, error) in
            if error == nil {
                let modifiedURLString = NSString(format: LocalizableString.BrizeoMailDescription.rawValue as NSString, st!)
                let modifiedString = NSString(format: LocalizableString.CheckItOutHere.rawValue as NSString, url!, url!)
                let modifiedSubString = NSString(format: "%@%@", modifiedURLString, modifiedString)
                let width = self.view.frame.size.width
                let mailContent = NSString(format: LocalizableString.BrizeoMailContent.rawValue as NSString, width, width * 0.9, (User.current()?.displayName)!, modifiedSubString)
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.setToRecipients(fullNameArr)
                mailComposerVC.setSubject(LocalizableString.TryBrizeo.localizedStringWithArguments([(User.current()?.displayName)!]))
                mailComposerVC.setMessageBody(mailContent as String, isHTML: true)
                if MFMailComposeViewController.canSendMail() {
                    
                    self.present(mailComposerVC, animated: true, completion: nil)
                } else {
                    self.showAlert(LocalizableString.CouldNotSendEmail.localizedString, message: LocalizableString.PleaseTryAgain.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                }
            }
        })
    }
    
    @IBAction func onRewardsButtonClicked(_ sender: UIButton) {
        if let url = URL(string: AppURL.RewardsURL) , UIApplication.shared.canOpenURL(url) {
            Helper.openURL(url: url)
        }
    }
    
    // MARK: - Observers
    
    override func keyboardWillHide(_ notification: Foundation.Notification) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func keyboardWillAppear(_ notification: Foundation.Notification) {
        scrollView.setContentOffset(CGPoint(x: 0, y: emailTextView.frame.origin.y - 10.0), animated: true)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension InviteViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - FBSDKSharingDelegate
extension InviteViewController: FBSDKSharingDelegate {
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print(results)
        print(sharer)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        FBSDKShareDialog.show(from: self, with: sharer.shareContent, delegate: nil)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension InviteViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
