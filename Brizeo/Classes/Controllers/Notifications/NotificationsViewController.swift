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
    func notificationCell(cell: UITableViewCell, didClickedApprove likerView: LikerView)
    func notificationCell(cell: UITableViewCell, didClickedDecline likerView: LikerView)
}

protocol NotificationsViewControllerDelegate: class {
    
    func loadNotifications(for type: NotificationType, completionHandler: @escaping ([Notification]?) -> Void)
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
        static let likesCellHeight: CGFloat = 93.0
        static let peopleCellHeight: CGFloat = 62.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var notifications: [Notification]?
    var contentType: NotificationType = .momentsLikes
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
        
        if notifications == nil || notifications?.count == 0 {
            loadNotifications()
        }
    }
    
    // MARK: - Private methods
    
    @objc fileprivate func refreshTableView() {
        loadNotifications()
    }
    
    fileprivate func loadNotifications() {
        
        delegate?.loadNotifications(for: contentType, completionHandler: { (loadedNotifications) in
            
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
    
    fileprivate func declineNotification(with sender: User, completion: @escaping (Void) -> Void) {
        showBlackLoader()
        
        MatchesProvider.declineMatch(for: sender) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    completion()
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    
    fileprivate func approveNotification(with sender: User, completion: @escaping (Void) -> Void) {
        showBlackLoader()
        
        MatchesProvider.approveMatch(for: sender) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    completion()
                    
                    if sender.status == .isMatched {
                        let matchingController: MatchViewController = Helper.controllerFromStoryboard(controllerId: "MatchViewController")!
                        matchingController.user = sender
                        
                        Helper.currentTabNavigationController()?.pushViewController(matchingController, animated: true)
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
            let displayName = notification.senderUser?.displayName ?? "Somebody"
            let time = notification.createdAt?.intervalString(toDate: Date()) ?? ""
            
            cell.generateText(with: displayName, time: time)

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
            
            let time = notification.createdAt?.intervalString(toDate: Date()) ?? ""
            cell.commentTimeLabel.text = time
            cell.generateText(with: notification.senderUser?.displayName ?? "", "")
            
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
        }
    }
    
    func notificationCell(cell: UITableViewCell, didClickedApprove likerView: LikerView) {
        showBlackLoader()
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("No index path for notification")
            return
        }
        
        let notification = notifications![indexPath.row]
        
        guard let sender = notification.senderUser else {
            return
        }
        
        approveNotification(with: sender) {
            self.tableView.reloadData()
        }
    }
    
    func notificationCell(cell: UITableViewCell, didClickedDecline likerView: LikerView) {
        
        showBlackLoader()
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("No index path for notification")
            return
        }
        
        let notification = notifications![indexPath.row]
        
        guard let sender = notification.senderUser else {
            return
        }
        
        declineNotification(with: sender) {
            self.tableView.reloadData()
        }
    }
}

