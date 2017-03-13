//
//  NotificationsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SDWebImage

protocol NotificationsTableViewCellDelegate: class {
    func notificationCellDidClickedOnProfile(cell: UITableViewCell)
    func notificationCellDidClickedOnImage(cell: UITableViewCell)
    func notificationCell(cell: UITableViewCell, didClickedApprove likerView: LikerView)
    func notificationCell(cell: UITableViewCell, didClickedDecline likerView: LikerView)
}

class NotificationsViewController: UIViewController {

    // MARK: - Types
    
    enum NotificationContentType {
        case likes
        case people
    }
    
    struct StoryboardIds {
        static let likesCellId = "Likes"
        static let peopleCellId = "People"
        static let mediaControllerId = "MediaViewController"
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        
    }
    
    struct Constants {
        static let likesCellHeightCoef: CGFloat = 185.0 / 1027.0
        static let peopleCellHeightCoef: CGFloat = 124.0 / 1027.0
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var notifications: [Notification]?
    var contentType: NotificationContentType = .likes
    var index: Int = 0
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadNotifications()
    }
    
    // MARK: - Private methods
    
    fileprivate func loadNotifications() {
        
    }
    
    fileprivate func showUserProfile(with user: User) {
        
        if user.objectId == UserProvider.shared.currentUser!.objectId { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            Helper.initialNavigationController().pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            otherPersonProfileController.userId = user.objectId
            navigationController?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: move content type somewhere inside notification object
        
        if contentType == .likes {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIds.likesCellId, for: indexPath) as! LikesNotificationTableViewCell
            let notification = notifications![indexPath.row]
            
            cell.delegate = self
//            cell.likeUserImage.sd_setImage(with: URL(string: notification.object(forKey: "userImage") as! String)!)
//            cell.likedMomentImage.sd_setImage(with: URL(string: notification.object(forKey: "momentImage") as! String)!)
//            cell.generateText(with: notification.object(forKey: "userName") as! String, time: notification.object(forKey: "timeframe") as! String)

            return cell
        } else { // people
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIds.peopleCellId, for: indexPath) as! PeopleNotificationTableViewCell
//            let notification = notifications.object(at: indexPath.row) as! NSDictionary
//            
//            cell.delegate = self
//            cell.commentUserImage.sd_setImage(with: URL(string: notification.object(forKey: "userImage") as! String)!)
//            cell.commentTimeLabel.text = "2d"//notification.object(forKey: "timeframe") as? String
//            cell.generateText(with: "Jonathan Harrison", "John.H")
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if contentType == .likes {
            return tableView.frame.height * Constants.likesCellHeightCoef
        } else {
            return tableView.frame.height * Constants.peopleCellHeightCoef
        }
    }
}

// MARK: - NotificationTableViewCellDelegate
extension NotificationsViewController: NotificationsTableViewCellDelegate {
    
    func notificationCellDidClickedOnImage(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let mediaController: MediaViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.mediaControllerId)!
        mediaController.isSharingEnabled = true
//        mediaController.moment = moment
        
        Helper.initialNavigationController().pushViewController(mediaController, animated: true)
    }
    
    func notificationCellDidClickedOnProfile(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let notification = notifications![indexPath.row]
//        showUserProfile(with: )
    }
    
    func notificationCell(cell: UITableViewCell, didClickedApprove likerView: LikerView) {
        showBlackLoader()
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("No index path for notification")
            return
        }
        
        let notification = notifications![indexPath.row]
        
        showBlackLoader()
        
//        MatchesProvider.approveMatch(for: user) { (result) in
//            
//            switch result {
//            case .success(_):
//                
//                self.hideLoader()
//                likerView.operateStatus(status: user.status)
//                
//                // TODO: check whether the status is matched. If yes - show matching page
//                if user.status == .isMatched {
//                    let matchingController: MatchViewController = Helper.controllerFromStoryboard(controllerId: "MatchViewController")!
//                    matchingController.user = user
//                    
//                    Helper.initialNavigationController().pushViewController(matchingController, animated: true)
//                }
//                
//                break
//            case .failure(let error):
//                
//                SVProgressHUD.showError(withStatus: error.localizedDescription)
//                break
//            default:
//                break
//            }
//        }
    }
    
    func notificationCell(cell: UITableViewCell, didClickedDecline likerView: LikerView) {
        
        showBlackLoader()
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("No index path for notification")
            return
        }
        
        let notification = notifications![indexPath.row]
        
        showBlackLoader()
        
//        MatchesProvider.declineMatch(for: user) { (result) in
//            
//            switch result {
//            case .success(_):
//                
//                self.hideLoader()
//                likerView.operateStatus(status: user.status)
//                break
//            case .failure(let error):
//                
//                SVProgressHUD.showError(withStatus: error.localizedDescription)
//                break
//            default:
//                break
//            }
//        }
    }
}

