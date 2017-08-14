//
//  MainTabBarController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/26/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Applozic

class MainTabBarController: UITabBarController {
    
    // MARK: - Types
    
    struct StoryboardIds {
        static let personalTabsController = "PersonalTabsViewController"
    }
    
    struct Constants {
        static let logoHeight: CGFloat = 25.0
    }
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if let items = tabBar.items {
            for item in items {
                item.image = item.image!.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage!.withRenderingMode(.alwaysOriginal)
            }
        }
        
        // update badge number for unread messages
        let number = ChatProvider.totalUnreadCount()
        if number != -1 {
            setMessageBadgeNumber(number)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationsNumberWasChanged(notification:)), name: NSNotification.Name(rawValue: notificationsBadgeNumberWasChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessagesNumberWasChanged(notification:)), name: NSNotification.Name(rawValue: messagesBadgeNumberWasChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessagesNumberWasChangedFromApplozic(notification:)), name: NSNotification.Name(rawValue: NEW_MESSAGE_NOTIFICATION), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = navigationController {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizableString.Back.localizedString, style: .plain, target: nil, action: nil)
            
            if navigationController.viewControllers.count < 3 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_search").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onRightButtonClicked(sender:)))
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_settings").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onLeftButtonClicked(sender:)))
                navigationItem.leftBarButtonItem?.width = #imageLiteral(resourceName: "ic_search").size.width
            }
        }
        
        showLogoIfNeeds()
    }
    
    // MARK: - Public methods
    
    func notificationsNumberWasChanged(notification: NSNotification) {
        
        guard let items = tabBar.items else {
            return
        }
        
        let notificationItem = items[3]
        
        guard let number = notification.userInfo?["number"] as? Int else {
            return
        }
        
        notificationItem.badgeValue = number == 0 ? nil : "\(number)"
        
        let messagesNumber = ChatProvider.totalUnreadCount()
        if messagesNumber == -1 { // dont use message number
            UIApplication.shared.applicationIconBadgeNumber = number
        } else {
            UIApplication.shared.applicationIconBadgeNumber = number + messagesNumber
            
            // update message badge number
            items[4].badgeValue = messagesNumber == 0 ? nil : "\(messagesNumber)"
        }
    }
    
    func unreadMessagesNumberWasChanged(notification: NSNotification) {
        
        guard let items = tabBar.items else {
            return
        }
        
        let notificationItem = items[4]
        
        guard let number = notification.userInfo?["number"] as? Int else {
            return
        }
        
        notificationItem.badgeValue = number == 0 ? nil : "\(number)"
        
        if let messagesNumberStr = items[3].badgeValue, let messagesNumber = Int(messagesNumberStr) {
            UIApplication.shared.applicationIconBadgeNumber = number + messagesNumber
        } else {
            UIApplication.shared.applicationIconBadgeNumber = number
        }
    }
    
    func unreadMessagesNumberWasChangedFromApplozic(notification: NSNotification) {
        
        let number = ChatProvider.totalUnreadCount()
        
        if number != -1 {
            setMessageBadgeNumber(number)
            loadNotificationsToSetBadge()
        }
    }
    
    func shouldShowLogo() -> Bool {
        return true
    }
    
    // MARK: - Private methods
    
    fileprivate func setMessageBadgeNumber(_ number: Int) {
        
        guard let items = tabBar.items else {
            return
        }
        
        let notificationItem = items[4]
        
        notificationItem.badgeValue = number == 0 ? nil : "\(number)"
        
        if let messagesNumberStr = items[3].badgeValue, let messagesNumber = Int(messagesNumberStr) {
            UIApplication.shared.applicationIconBadgeNumber = number + messagesNumber
        } else {
            UIApplication.shared.applicationIconBadgeNumber = number
        }
    }

    fileprivate func showLogoIfNeeds() {
        if !shouldShowLogo() { return }
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_nav_logo"))
        imageView.contentMode = .scaleAspectFit
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        navigationItem.titleView = titleView
    }
    
    fileprivate func loadNotificationsToSetBadge() {
        
        NotificationProvider.getNotification(for: UserProvider.shared.currentUser!.objectId) { (result) in
            
            switch result {
            case .success(let notifications):
                
                let unreadNotifications = notifications.filter({ return !$0.isAlreadyViewed })
                let likesNotifications = unreadNotifications.filter({ $0.pushType == .momentsLikes })
                
                Helper.sendNotification(with: notificationsBadgeNumberWasChanged, object: nil, dict: [
                    "number": unreadNotifications.count,
                    "likesNumber": likesNotifications.count,
                    "peopleNumber": unreadNotifications.count - likesNotifications.count
                    ])
            case .failure(let error):
                print("Failure with getting notifications: \(error.localizedDescription)")
            default:
                break
            }
        }
    }
    
    // MARK: - Actions
    
    func onLeftButtonClicked(sender: UIBarButtonItem) {
        let personalController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.personalTabsController)!
        navigationController?.pushViewController(personalController, animated: true)
    }
    
    func onRightButtonClicked(sender: UIBarButtonItem) {
        let inviteFriendView: InviteFriendsView = InviteFriendsView.loadFromNib()
        inviteFriendView.present(on: navigationController!.view)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
/*
        if viewController.isKind(of: ChatListViewController.self) {
            ChatProvider.startChat(with: nil, from: self)
            
            return false
        }
 */
        return true
    }
}
