//
//  ChooseView.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Branch
import SVProgressHUD
import FBSDKShareKit
import FBSDKMessengerShareKit
import MessageUI
import Social

class ChooseView: UIView {

    // MARK: - Types
    
    enum Items: Int {
        case sms = 0
        case messanger
        case whatsapp
        case email
        case twitter
        
        var data: (String, UIImage) {
            switch self {
            case .sms:
                return (LocalizableString.SMSShare.localizedString, #imageLiteral(resourceName: "ic_share_message"))
            case .messanger:
                return (LocalizableString.MessangerShare.localizedString, #imageLiteral(resourceName: "ic_share_facebook"))
            case .whatsapp:
                return (LocalizableString.WhatsappShare.localizedString, #imageLiteral(resourceName: "ic_share_whatsapp"))
            case .email:
                return (LocalizableString.EmailShare.localizedString, #imageLiteral(resourceName: "ic_share_email"))
            case .twitter:
                return (LocalizableString.TwitterShare.localizedString, #imageLiteral(resourceName: "ic_share_twitter"))
            }
        }
        
        static var count: CGFloat = 5.0
    }
    
    struct Constants {
        static let rowHeight: CGFloat = 37.0
        static let bottomViewHeight: CGFloat = 50.0
        static let sizeCoef: CGFloat = 441.0 / 750.0
        static let animationDuration = 0.3
        static let bottomMargin: CGFloat = 30.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerTableViewCell()
        
        tableViewHeightConstraint.constant = Items.count * Constants.rowHeight
        
        let desiredHeight = ChooseView.desiredHeight()
        let desiredWidth = Constants.sizeCoef * UIScreen.main.bounds.width
        
        let newFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: desiredWidth, height: desiredHeight))
        frame = newFrame
    }
    
    // MARK: - Public methods
    
    func present(on view: UIView) {
        center = view.center
        var newFrame = frame
        newFrame.origin.y = UIScreen.main.bounds.height
        frame = newFrame
        
        view.addSubview(self)
        UIView.animate(withDuration: Constants.animationDuration) {
            var newFrame = self.frame
            newFrame.origin.y = newFrame.origin.y - self.frame.height - Constants.bottomMargin
            self.frame = newFrame
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func registerTableViewCell() {
        tableView.register(UINib(nibName: ChooseTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ChooseTableViewCell.identifier)
    }
    
    fileprivate func generateBranchURL(handler: @escaping (String) -> Void) {
        // show loading
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        BranchProvider.generateShareURL { (url) in
            if let url = url {
                SVProgressHUD.dismiss()
                handler(url)
            } else {
                SVProgressHUD.showError(withStatus: LocalizableString.BranchUnavailable.localizedString)
                return
            }
        }
    }
    
    fileprivate func shareWithSMS(url: String) {
        if MFMessageComposeViewController.canSendText() {
            let modifiedURLString = LocalizableString.ShareDefaultText.localizedStringWithArguments([UserProvider.shared.currentUser!.displayName, url])
            let messageComposeVC = MFMessageComposeViewController()
            
            messageComposeVC.body = modifiedURLString
            messageComposeVC.delegate = Helper.initialNavigationController()
            messageComposeVC.messageComposeDelegate = Helper.initialNavigationController()
            messageComposeVC.recipients = nil
            
            Helper.initialNavigationController().present(messageComposeVC, animated: true, completion: nil)
        } else {
            SVProgressHUD.showError(withStatus: LocalizableString.ShareSmsFails.localizedString)
        }
    }

    fileprivate func shareWithTwitter(url: String) {
        let modifiedURLString = LocalizableString.ShareDefaultText.localizedStringWithArguments([UserProvider.shared.currentUser!.displayName, url])
        
        if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
            vc.setInitialText(modifiedURLString)
            vc.add(#imageLiteral(resourceName: "ic_brizeo_invite_image"))
            vc.add(URL(string: url))
            Helper.initialNavigationController().present(vc, animated: true, completion: nil)
        } else {
            SVProgressHUD.showError(withStatus: LocalizableString.ShareTwitterFails.localizedString)
        }
    }

    fileprivate func shareWithMessanger(url: String) {
        let content = FBSDKShareLinkContent()
        content.contentURL = URL(string: url)
        content.imageURL = URL(string: Configurations.Invite.previewURL)
        content.contentTitle = LocalizableString.TryBrizeo.localizedStringWithArguments([UserProvider.shared.currentUser!.displayName])
        content.contentDescription = LocalizableString.BrizeoShareDescription.localizedString
        
        FBSDKMessageDialog.show(with: content, delegate: self)
    }
    
    fileprivate func shareWithEmail(url: String) {
        let mailComposerVC = MFMailComposeViewController()
        let modifiedURLString = NSString(format: LocalizableString.BrizeoMailDescription.rawValue as NSString, "")
        let modifiedString = NSString(format: LocalizableString.CheckItOutHere.rawValue as NSString, url, url)
        let modifiedSubString = NSString(format: "%@%@", modifiedURLString, modifiedString)
        let width =  UIScreen.main.bounds.width
        let mailContent = NSString(format: LocalizableString.BrizeoMailContent.rawValue as NSString, width, width * 0.9, UserProvider.shared.currentUser!.displayName, modifiedSubString)
        mailComposerVC.mailComposeDelegate = Helper.initialNavigationController()
        mailComposerVC.setSubject(LocalizableString.TryBrizeo.localizedStringWithArguments([UserProvider.shared.currentUser!.displayName]))
        mailComposerVC.setMessageBody(mailContent as String, isHTML: true)
        
        if MFMailComposeViewController.canSendMail() {
            Helper.initialNavigationController().present(mailComposerVC, animated: true, completion: nil)
        } else {
            SVProgressHUD.showError(withStatus: LocalizableString.CouldNotSendEmail.localizedString)
        }
}

    fileprivate func shareWithWhatsapp(url: String) {
        let modifiedURLString = LocalizableString.ShareDefaultText.localizedStringWithArguments([UserProvider.shared.currentUser!.displayName, url])
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
            SVProgressHUD.showError(withStatus: LocalizableString.ShareWhatsappFails.localizedString)
        }
    }

    // MARK: - Class methods

    class func desiredHeight() -> CGFloat {
        return Items.count * Constants.rowHeight + Constants.bottomViewHeight
    }
    
    // MARK: - Actions
    
    @IBAction func onCancelButtonClicked(sender: UIButton) {
        removeFromSuperview()
    }
}

// MARK: - UITableViewDataSource
extension ChooseView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(Items.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChooseTableViewCell = tableView.dequeueCell(withIdentifier: ChooseTableViewCell.identifier, for: indexPath)
        
        if let item = Items(rawValue: indexPath.row) {
            cell.iconImageView.image = item.data.1
            cell.titleLabel.text = item.data.0
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChooseView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Items(rawValue: indexPath.row)! {
        case .sms:
            generateBranchURL(handler: { (url) in
                self.shareWithSMS(url: url)
            })
            break
        case .messanger:
            generateBranchURL(handler: { (url) in
                self.shareWithMessanger(url: url)
            })
            break
        case .whatsapp:
            generateBranchURL(handler: { (url) in
                self.shareWithWhatsapp(url: url)
            })
            break
        case .email:
            generateBranchURL(handler: { (url) in
                self.shareWithEmail(url: url)
            })
            break
        case .twitter:
            generateBranchURL(handler: { (url) in
                self.shareWithTwitter(url: url)
            })
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
}

// MARK: - FBSDKSharingDelegate
extension ChooseView: FBSDKSharingDelegate {
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print(results)
        print(sharer)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        FBSDKShareDialog.show(from: Helper.initialNavigationController(), with: sharer.shareContent, delegate: nil)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
    }
}
