////
////  ChatViewController.swift
////  Brizeo
////
////  Created by Giovanny Orozco on 4/20/16.
////  Copyright © 2016 Kogi Mobile. All rights reserved.
////
//
//import UIKit
//import Parse
//import SVProgressHUD
//import Mixpanel
//import AVFoundation
//import AVKit
//import AddressBook
//import AddressBookUI
//import NYTPhotoViewer
//import CoreLocation
//import MapKit
//
//class ChatViewController: ATLConversationViewController {
//
//    // MARK - Types
//    
//    struct StoryboardIds {
//        static let profileController = "OtherProfileViewControlle"
//    }
//    
//    // MARK: - Properties
//    
//    fileprivate var participants = [User]()
//    fileprivate let dateFormatter = DateFormatter()
//    fileprivate var isFirstmessageSend = false
//    
//    //MARK: - Controller lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        layerClient = LayerManager.sharedManager.layerClient
//        
//        setupNotifications()
//        
//        // Setup the dateformatter used by the dataSource.
//        dateFormatter.dateStyle = DateFormatter.Style.short
//        dateFormatter.timeStyle = DateFormatter.Style.short
//        
//        delegate = self
//        dataSource = self
//        dateDisplayTimeInterval = 1
//        
//        ATLOutgoingMessageCollectionViewCell.appearance().messageTextColor = UIColor.white
////        ATLMessageCollectionViewCell.appearance().messageTextCheckingTypes = [.link, .phoneNumber]
//        
//        let participantIDs = conversation.participants.map { $0.userID! }
//        
//        User.getUsers(participantIDs) { [weak self] ( users, error) in
//            
//            if let users = users {
//                self?.participants = users
//                self?.setupTableViewHeader()
//            } else {
//                SVProgressHUD.showError(withStatus: error?.localizedDescription)
//            }
//        }
//        
//        let backButton = UIBarButtonItem(title: LocalizableString.Back.localizedString, style: .plain, target: self, action: #selector(onBackButtonClicked))
//        navigationItem.leftBarButtonItem = backButton
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ATLUserDidTapLink, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ATLUserDidTapPhoneNumber, object: nil)
//    }
//    
//    //MARK: - Private methods
//    
//    fileprivate func setupTableViewHeader() {
//        let currentUser = User.current()!
//        let participant = participants.filter { $0.userID != currentUser.objectId }.first ?? currentUser
//        let participantView = ParticipantView.participantView(imageUrl: participant.avatarImageURL, userName: participant.displayName)
//        
//        participantView.actionBlock = { sender in
//            let profileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileController)!
//            profileController.user = participant
//            
//            Helper.initialNavigationController().pushViewController(profileController, animated: true)
//        }
//        
//        navigationItem.titleView = participantView
//    }
//    
//    fileprivate func setupNotifications() {
//    
//        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.messageWithURLSelected(_:)), name: NSNotification.Name.ATLUserDidTapLink, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.messageWithPhoneNumberSelected(_:)), name: NSNotification.Name.ATLUserDidTapPhoneNumber, object: nil)
//    }
//    
//    // MARK: - Observer methods
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey:Any]?, context: UnsafeMutableRawPointer?) {
//        
//        if let messagePart = object as? LYRMessagePart {
//            if messagePart.transferStatus == .complete {
//                DispatchQueue.main.async(execute: { () -> Void in
//                    SVProgressHUD.dismiss()
//                    
//                    let playerVC = AVPlayerViewController()
//                    let player = AVPlayer(url: messagePart.fileURL!)
//                    playerVC.player = player
//                    
//                    Helper.initialNavigationController().present(playerVC, animated: true, completion: nil)
//                    player.play()
//                })
//            }
//        }
//    }
//    
//    //MARK: - Notifications
//    
//    func messageWithURLSelected(_ notification: Foundation.Notification) {
//        guard let url = notification.object as? URL else {
//            return
//        }
//        
//        Helper.openURL(url: url)
//    }
//    
//    func messageWithPhoneNumberSelected(_ notification: Foundation.Notification) {
//        
//        let phoneNumber = notification.object as! String
//        messageInputToolbar.textInputView.resignFirstResponder()
//        
//        let optionsAlert = DeviceAction.createActionSeetActions(phoneNumber) { action in
//            
//            switch action {
//            case .createContact:
//                let userRecord: ABRecord = ABPersonCreate().takeRetainedValue()
//                ABRecordSetValue(userRecord, kABPersonFirstNameProperty, "" as CFTypeRef!, nil)
//                
//                let phoneNumbers: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
//                ABMultiValueAddValueAndLabel(phoneNumbers, phoneNumber as CFTypeRef!, kABPersonPhoneMainLabel, nil)
//                ABRecordSetValue(userRecord, kABPersonPhoneProperty, phoneNumbers, nil)
//                
//                let controller = ABNewPersonViewController()
//                controller.newPersonViewDelegate = self
//                controller.displayedPerson = userRecord
//                Helper.initialNavigationController().pushViewController(controller, animated: true)
//                break
//            default:
//                print(action)
//            }
//        }
//                
//        self.present(optionsAlert, animated: true, completion: nil)
//    }
//    
//    @objc(conversationViewController:messagesForMediaAttachments:) func conversationViewController(_ viewController: ATLConversationViewController, messagesFor mediaAttachments: [ATLMediaAttachment]) -> NSOrderedSet? {
//        
//        let messages = NSMutableOrderedSet()
//        for attachment in mediaAttachments {
//            
//            let messageParts = ATLMessagePartsWithMediaAttachment(attachment)
//            let pushText = LocalizableString.SomebodySentYouAMessage.localizedStringWithArguments([User.current()!.displayName])
//            if let message = ATLMessageForParts(self.layerClient, messageParts, pushText, Resources.pushNotificationSound) {
//                messages.add(message)
//            }
//        }
//        return messages
//    }
//    
//    // MARK: - Actions
//    
//    func onBackButtonClicked() {
//        self.queryController.delegate = nil
//        _ = navigationController?.popViewController(animated: true)
//    }
//}
//
////MARK: - ATLConversationViewControllerDataSource Methods
//extension ChatViewController: ATLConversationViewControllerDataSource {
//
//    func conversationViewController(_ conversationViewController: ATLConversationViewController, participantFor identity: LYRIdentity) -> ATLParticipant {
//    
//        if participants.count > 0 {
//            let user = participants.filter { $0.objectId == identity.userID }.first!
//            return user
//        }
//        
//        return identity
//    }
//    
//    func conversationViewController(_ conversationViewController: ATLConversationViewController, attributedStringForDisplayOf date: Date) -> NSAttributedString {
//    
//        let attributes: NSDictionary = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.gray]
//        return NSAttributedString(string: dateFormatter.string(from: date), attributes: attributes as? [String:AnyObject])
//    }
//    
//    func conversationViewController(_ conversationViewController: ATLConversationViewController, attributedStringForDisplayOfRecipientStatus recipientStatus: [AnyHashable: Any]) -> NSAttributedString {
//        
//        let mergedStatuses = NSMutableAttributedString()
//        let recipientStatusDict = recipientStatus as NSDictionary
//        let allKeys = recipientStatusDict.allKeys as NSArray
//        allKeys.enumerateObjects(options: NSEnumerationOptions.concurrent) { (participant, _, _) in
//            let participantAsString = participant as! String
//            if (participantAsString == self.layerClient.authenticatedUser?.userID) {
//                return
//            }
//            
//            var recpVal = LocalizableString.MessageSending.localizedString
//            let textColor = UIColor.lightGray
//            let status = LYRRecipientStatus(rawValue: Int((recipientStatusDict[participantAsString]! as AnyObject).uintValue))!
//            
//            switch status {
//            case .sent:
//                recpVal = LocalizableString.MessageSent.localizedString
//            case .delivered:
//                recpVal = LocalizableString.MessageDelivered.localizedString
//            case .read:
//                recpVal = LocalizableString.MessageRead.localizedString
//            default:
//                recpVal = LocalizableString.MessageSending.localizedString
//            }
//            
//            let statusString: NSAttributedString = NSAttributedString(string: recpVal, attributes: [NSForegroundColorAttributeName: textColor])
//            mergedStatuses.append(statusString)
//        }
//        return mergedStatuses
//    }
//
//}
//
////MARK: - ATLConversationViewControllerDelegate Methods
//extension ChatViewController: ATLConversationViewControllerDelegate {
//
//    func conversationViewController(_ viewController: ATLConversationViewController, didSend message: LYRMessage) {
//        
//        let user = User.current()!
//        
//        if let messagePart = message.parts.first {
//            if messagePart.mimeType == ATLMIMETypeLocation {
//                SVProgressHUD.show()
//            }
//        }
//        
//        if (conversation.totalNumberOfMessages == 1) {
//            if !self.isFirstmessageSend && message.sender.userID == user.objectId {
//                self.fireInitiateChatEvent()
//            }
//        }
//        
//        user.lastActiveTime = Date()
//        user.saveInBackground()
//        
//        if message.sender.userID == user.objectId {
//            self.isFirstmessageSend = true
//        }
//        
//        findWhoInitiatedChat()
//    }
//    
//    func conversationViewController(_ viewController: ATLConversationViewController, didFailSending message: LYRMessage, error: Error) {
//        
//        SVProgressHUD.dismiss()
//        print("Message failed to sent with error: \(error)")
//    }
//    
//    func conversationViewController(_ viewController: ATLConversationViewController, didSelect message: LYRMessage) {
//        
//        guard let messagePart = message.parts.first else {
//            return
//        }
//        
//        let currentUser = User.current()!
//        
//        if (messagePart.mimeType == ATLMIMETypeLocation) {
//            
//            do {
//                let dict = try JSONSerialization.jsonObject(with: messagePart.data!, options: .allowFragments) as! NSDictionary
//                let lat = dict[ATLLocationLatitudeKey] as! NSNumber
//                let long = dict[ATLLocationLongitudeKey] as! NSNumber
//                let coord = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: long.doubleValue)
//                var itemName = LocalizableString.Me.localizedString
//                
//                if message.sender.userID != currentUser.objectId {
//                    let userID = message.sender.userID
//                    let user = participants.filter { $0.objectId == userID }.first!
//                    itemName = user.displayName
//                }
//                
//                let regionDistance: CLLocationDistance = 1000
//                let regionSpan = MKCoordinateRegionMakeWithDistance(coord, regionDistance, regionDistance)
//                let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
//                let placemark = MKPlacemark(coordinate: coord, addressDictionary: nil)
//                let mapItem = MKMapItem(placemark: placemark)
//                mapItem.name = itemName
//                mapItem.openInMaps(launchOptions: options)
//            } catch {
//                
//                SVProgressHUD.showError(withStatus: LocalizableString.ShowLocationError.localizedString)
//            }
//        } else if (messagePart.mimeType == ATLMIMETypeVideoMP4) {
//            
//            let videoMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeVideoMP4)
//            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
//            let basePath = (paths.count > 0) ? paths.first : nil
//            let symlinkedMediaBaseURL = URL(fileURLWithPath: basePath!, isDirectory: true)
//            let mediaBaseURL = symlinkedMediaBaseURL.appendingPathComponent(LayerKey.ATLMediaViewControllerSymLinkedMediaTempPath).absoluteURL
//            
//            try! FileManager.default.createDirectory(at: mediaBaseURL, withIntermediateDirectories: true, attributes: nil)
//            
//            if let videoMessagePart = videoMessagePart {
//                
//                if videoMessagePart.transferStatus == .readyForDownload || videoMessagePart.transferStatus == .downloading {
//                    do {
//                        SVProgressHUD.setDefaultMaskType(.clear)
//                        SVProgressHUD.show(withStatus: LocalizableString.LoadingVideo.localizedString)
//                        try videoMessagePart.downloadContent()
//                        videoMessagePart.addObserver(self, forKeyPath: "transferStatus", options: .new, context: nil)
//                    } catch {
//                        SVProgressHUD.showError(withStatus: LocalizableString.ShowVideoError.localizedString)
//                    }
//                } else if let videoUrl = videoMessagePart.fileURL {
//                    let playerVC = AVPlayerViewController()
//                    let player = AVPlayer(url: videoUrl)
//                    playerVC.player = player
//                    
//                    Helper.initialNavigationController().present(playerVC, animated: true, completion: nil)
//                    player.play()
//                }
//            } else {
//                SVProgressHUD.showError(withStatus: LocalizableString.ShowVideoError.localizedString)
//            }
//        } else if (messagePart.mimeType == ATLMIMETypeImageJPEG || messagePart.mimeType == ATLMIMETypeImagePNG) {
//            
//            var imageMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEG)
//            
//            if imageMessagePart == nil {
//                imageMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImagePNG)
//            }
//            
//            if let imageMessagePart = imageMessagePart {
//                
//                var data = Data()
//                
//                if let imageData = imageMessagePart.data {
//                    data = imageData
//                } else if let imageUrl = imageMessagePart.fileURL {
//                    data = try! Data(contentsOf: imageUrl)
//                }
//                
//                let photoViewer = NYTPhotosViewController(photos: [CaptionedPhoto(imageData: data, captionTitle:"")])
//                Helper.initialNavigationController().present(photoViewer, animated: true, completion: nil)
//            } else {
//                SVProgressHUD.showError(withStatus: LocalizableString.ShowImageError.localizedString)
//            }
//        }
//    }
//    
//    func conversationViewController(_ conversationViewController: ATLConversationViewController, configureCell cell: UICollectionViewCell, for message: LYRMessage) {
//        
//        if let messagePart = message.parts.first {
//            if messagePart.mimeType == ATLMIMETypeLocation {
//                SVProgressHUD.dismiss()
//            }
//        }
//    }
//}
//
////MARK: - ATLMessageInputToolbarDelegate Methods
//extension ChatViewController {
//
//    override func messageInputToolbarDidType(_ messageInputToolbar: ATLMessageInputToolbar) {
//        
//        if !SVProgressHUD.isVisible() {
//            super.messageInputToolbarDidType(messageInputToolbar)
//        }
//    }
//    
//    override func messageInputToolbarDidEndTyping(_ messageInputToolbar: ATLMessageInputToolbar) {
//        
//        if !SVProgressHUD.isVisible() {
//            super.messageInputToolbarDidEndTyping(messageInputToolbar)
//        }
//    }
//    
//    override func messageInputToolbar(_ messageInputToolbar: ATLMessageInputToolbar, didTapLeftAccessoryButton leftAccessoryButton: UIButton) {
//        
//        if !SVProgressHUD.isVisible() {
//            super.messageInputToolbar(messageInputToolbar, didTapLeftAccessoryButton: leftAccessoryButton)
//        }
//    }
//    
//    override func messageInputToolbar(_ messageInputToolbar: ATLMessageInputToolbar, didTapRightAccessoryButton rightAccessoryButton: UIButton) {
//        
//        if !SVProgressHUD.isVisible() {
//            super.messageInputToolbar(messageInputToolbar, didTapRightAccessoryButton: rightAccessoryButton)
//        }
//    }
//}
//
//// MARK: - Mix Panel Events
//extension ChatViewController {
//
//    fileprivate func findWhoInitiatedChat() {
//        
//        let user = User.current()!
//        let query = PFQuery(className: "userDetail")
//        
//        query.whereKey("user", equalTo: user)
//        query.findObjectsInBackground { (objects, error) -> Void in
//            
//            if error == nil {
//                if objects!.count != 0 {
//                    
//                    let obj: PFObject = objects![0]
//                    let gender: NSNumber! = obj["gender"] as! NSNumber
//                    
//                    if gender.intValue == 1 {
//                        self.fireChatInitiatedByMenEvent()
//                    } else if gender.intValue == 2 {
//                        self.fireChatInitiatedByWomenEvent()
//                    }
//                }
//            }
//        }
//    }
//    
//    func fireInitiateChatEvent() {
//        
//        let user = User.current()!
//        let propertyDict: [String:AnyObject] = ["user_id": user.objectId! as AnyObject]
//        let mixPanel = Mixpanel.sharedInstance()
//        mixPanel.track("Initiate_Chat", properties: propertyDict)
//    }
//    
//    func fireChatInitiatedByMenEvent() {
//        
//        let user = User.current()!
//        let propertyDict: [String:AnyObject] = ["user_id": user.objectId! as AnyObject]
//        let m = Mixpanel.sharedInstance()
//        m.track("Chat_Initiated_By_Men", properties: propertyDict)
//    }
//    
//    func fireChatInitiatedByWomenEvent() {
//        
//        let user = User.current()!
//        let propertyDict: [String:AnyObject] = ["user_id": user.objectId! as AnyObject]
//        let m = Mixpanel.sharedInstance()
//        m.track("Chat_Initiated_By_Women", properties: propertyDict)
//    }
//}
//
//extension ChatViewController: ABNewPersonViewControllerDelegate {
//    
//    func newPersonViewController(_ newPersonView: ABNewPersonViewController, didCompleteWithNewPerson person: ABRecord?) {
//        
//        // TODO:
//////        let navigationC = baseController as! UINavigationController
////        navigationC.popViewController(animated: true)
//    }
//}
