//
//  NotificationsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftDate
import FormatterKit
import SVProgressHUD

enum NotificationContentType {
    case likes
    case people
}

protocol NotificationsTableViewCellDelegate: class {
    
    func notificationCellDidClickedOnProfile(cell: UITableViewCell)
    func notificationCellDidClickedOnImage(cell: UITableViewCell)
}

protocol NotificationsViewControllerDelegate: class {
    
    func loadNotifications(for type: NotificationType?, _ withLoading: Bool, completionHandler: @escaping ([Notification]?) -> Void)
}

class NotificationsViewController: UIViewController {

    // MARK: - Types
    
    struct StoryboardIds {
        static let likesCellId = "Likes"
        static let peopleCellId = "People"
        static let mediaControllerId = "MediaViewController"
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        
    }
    
    struct Constants {
        static let likesCellHeight: CGFloat = 85.0
        static let peopleCellHeight: CGFloat = 85.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var notifications: [Notification]?
    var contentType: NotificationType?
    var index: Int = 0
    var topRefresher: UIRefreshControl!
    weak var delegate: NotificationsViewControllerDelegate?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(NotificationsViewController.refreshTableView), for: .valueChanged)
        tableView.addSubview(topRefresher)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadNotifications(true)
    }
    
    // MARK: - Public method
    
    func reloadContent() {
        
        delegate?.loadNotifications(for: contentType, false, completionHandler: { (loadedNotifications) in
            
            if let loadedNotifications = loadedNotifications {
                self.notifications = loadedNotifications
                self.tableView.reloadData()
            }
            
            self.topRefresher.endRefreshing()
        })
    }
    
    // MARK: - Private methods
    
    @objc fileprivate func refreshTableView() {
        loadNotifications(false)
    }
    
    fileprivate func loadNotifications(_ withLoading: Bool) {
        
        delegate?.loadNotifications(for: contentType, withLoading, completionHandler: { (loadedNotifications) in
            
            if let loadedNotifications = loadedNotifications {
                self.notifications = loadedNotifications
                self.tableView.reloadData()
            }
            
            self.topRefresher.endRefreshing()
        })
    }
    
    fileprivate func showUserProfile(with user: User) {
        
        if user.objectId == UserProvider.shared.currentUser!.objectId { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            Helper.currentTabNavigationController()?.pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            otherPersonProfileController.userId = user.objectId
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if contentType == .momentsLikes {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIds.likesCellId, for: indexPath) as! LikesNotificationTableViewCell
            let notification = notifications![indexPath.row]
            
            cell.delegate = self
            
            // profile image
            if let profileUrl = notification.senderUser?.profileUrl {
                cell.likeUserImage.sd_setImage(with: profileUrl)
            } else {
                cell.likeUserImage.image = nil
            }
            
            // moment image url
            if let momentImageUrl = notification.moment?.imageUrl {
                cell.likedMomentImage.sd_setImage(with: momentImageUrl)
            } else {
                cell.likedMomentImage.image = nil
            }
            
            // name/time
            let displayName = notification.senderUser?.shortName ?? "Somebody"
            let time = notification.createDate?.naturalView ?? ""//notification.shortTime ?? ""
            cell.generateText(with: displayName, time: time)
            
            // already viewed
            cell.isAlreadyReviewed = notification.isAlreadyViewed

            return cell
        } else { // people
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIds.peopleCellId, for: indexPath) as! PeopleNotificationTableViewCell
            let notification = notifications![indexPath.row]
            
            cell.delegate = self
            
            if let profileUrl = notification.senderUser?.profileUrl {
                cell.commentUserImage.sd_setImage(with: profileUrl)
            } else {
                cell.commentUserImage.image = nil
            }
            
            // name/time
            let displayName = notification.senderUser?.shortName ?? "Somebody"
            let time = notification.createDate?.naturalView ?? ""
            cell.generateMatchingText(with: displayName, time: time, type: notification.pushType)
            
            // already viewed
            cell.isAlreadyReviewed = notification.isAlreadyViewed
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if contentType == .momentsLikes {
            return Constants.likesCellHeight
        } else {
            return Constants.peopleCellHeight
        }
    }
}

// MARK: - NotificationTableViewCellDelegate
extension NotificationsViewController: NotificationsTableViewCellDelegate {
    
    func notificationCellDidClickedOnImage(cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let notification = notifications![indexPath.row]
        if notification.isAlreadyViewed == false {
            NotificationProvider.markNotificationAsAlreadyViewed(notification, completion: nil)
            
            // decrease the badge number
            if let badgeNumberStr = tabBarItem.badgeValue, let badgeNumber = Int(badgeNumberStr) {
                Helper.sendNotification(with: notificationsBadgeNumberWasChanged, object: nil, dict: ["number": badgeNumber - 1])
            }
        }
        
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        
        mediaController.isSharingEnabled = true
        mediaController.moment = notification.moment
        
        Helper.currentTabNavigationController()?.pushViewController(mediaController, animated: true)
    }
    
    func notificationCellDidClickedOnProfile(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let notification = notifications![indexPath.row]
        
        if notification.isAlreadyViewed == false {
            NotificationProvider.markNotificationAsAlreadyViewed(notification, completion: nil)
            
            // decrease the badge number
            if let badgeNumberStr = tabBarItem.badgeValue, let badgeNumber = Int(badgeNumberStr) {
                Helper.sendNotification(with: notificationsBadgeNumberWasChanged, object: nil, dict: ["number": badgeNumber - 1])
            }
        }
        
        guard let senderUser = notification.senderUser else {
            return
        }
        
        if senderUser.objectId == UserProvider.shared.currentUser!.objectId { // show my profile
            
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            
            Helper.currentTabNavigationController()?.pushViewController(profileController, animated: true)
        } else {
            
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = senderUser
            otherPersonProfileController.userId = senderUser.objectId
            
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
            
            LocalyticsProvider.userGoProfileFromNotifications()
        }
    }
}

