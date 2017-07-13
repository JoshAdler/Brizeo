//
//  OtherPersonAboutViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework

let mutualFriendsNotification = "mutualFriendsNotification"

class OtherPersonAboutViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let inviteCellHeight: CGFloat = 70.0
        static let infoCellHeight: CGFloat = 231.5
        static let invitedByCellHeight: CGFloat = 60.0
        static let passionsCellHeight: CGFloat = 114.0
        static let headerViewHeight: CGFloat = 53.5
    }
    
    struct StoryboardIds {
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let inviteFaceUserCellId = "inviteFaceUserCellId"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var passionsTableView: UITableView!
    
    var mutualFriends: [User]?
    var mutualFriendsCount = 0 // RB: it is not the count of the value above
    var user: User!
    var locationString: String?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerHeaderViews()
        
        passionsTableView.rowHeight = UITableViewAutomaticDimension
        passionsTableView.estimatedRowHeight = 100.0
        
        if mutualFriends == nil {
            fetchMutualFriends()
        }
        
        // load user location
        LocationManager.getLocationString(for: user) { (location) in
            self.locationString = location
            self.passionsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func registerHeaderViews() {
        passionsTableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
    }
    
    fileprivate func fetchMutualFriends() {
        
        UserProvider.getMutualFriends(for: user) { (result) in
            switch result {
            case .success(let count, let users):
                
                // send notification
                let notification = UIKit.Notification(name: NSNotification.Name.init(rawValue: mutualFriendsNotification), object: nil, userInfo: ["mutualFriends": users, "count": count, "userId": self.user!.objectId])
                NotificationCenter.default.post(notification)
                
                self.mutualFriends = users
                self.passionsTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            case .failure(_):
                print("Failing mutual friends")
            default:
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension OtherPersonAboutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 { // passions
            return 1
        }
        
        if section == 2 { // details
            return user.hasInvitedByPerson ? 2 : 1 /* details with/out invited by */
        }
        
        if section == 3 { // mutual friends
            return mutualFriends?.count ?? 0
        }
        
        // RB Comment: When personal text is empty
        if user.personalText.numberOfCharactersWithoutSpaces() == 0 {
            return 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // text cell
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutTextTableViewCell.identifier, for: indexPath) as! OtherPersonAboutTextTableViewCell
            
            cell.titleLabel.text = user.personalText
            return cell
        } else if indexPath.section == 1 { // passions
            
            let cell: AboutPassionsTableViewCell = tableView.dequeueCell(withIdentifier: AboutPassionsTableViewCell.identifier, for: indexPath)
            let passions = user.passions
            
            if [passions].count >= Configurations.General.requiredMinPassionsCount {
                cell.setPassions(passions)
            }
            
            return cell
        } else if indexPath.section == 2 { // info cell
            if indexPath.row == 0 { // detail cell
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutInfoTableViewCell.identifier, for: indexPath) as! OtherPersonAboutInfoTableViewCell
                
                cell.applyUser(user: user)
                cell.applyLocationWithUser(user: user, locationString: locationString)
                cell.friendsLabel.text = "\(mutualFriends?.count ?? 0) mutual friends"
                
                return cell
            } else { // invited by
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutInvitedByTableViewCell.identifier, for: indexPath) as! OtherPersonAboutInvitedByTableViewCell
                
                cell.delegate = self
                cell.invitedByName = user.invitedByUserName ?? ""
                
                return cell
            }
        } else { // invite cell
            let mutualFriend = mutualFriends![indexPath.row]
            var cell: OtherPersonAboutInviteTableViewCell
            
            if mutualFriend.objectId != "0" {
                cell = tableView.dequeueCell(withIdentifier: OtherPersonAboutInviteTableViewCell.identifier, for: indexPath)
            } else {
                cell = tableView.dequeueCell(withIdentifier: StoryboardIds.inviteFaceUserCellId, for: indexPath)
            }
            
            cell.delegate = self
            cell.logoImageView.sd_setImage(with: mutualFriend.profileUrl)
            cell.titleLabel.text = mutualFriend.shortName
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension OtherPersonAboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 3 { // mutual friends
            let user = mutualFriends![indexPath.row]
            
            if user.facebookId == nil { // invite friend
                return
            }
            
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            
            otherPersonProfileController.user = user
            otherPersonProfileController.userId = user.objectId
            
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 { // text cell
            return UITableViewAutomaticDimension
        } else if indexPath.section == 1 { // passions
            return Constants.passionsCellHeight
        } else if indexPath.section == 2 { // info cell
            if indexPath.row == 0 { // details
                return UITableViewAutomaticDimension
                //return Constants.infoCellHeight
            } else { // invited by
                return Constants.invitedByCellHeight
            }
        } else {
            return Constants.inviteCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }
        
        let headerView: SettingsBigHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsBigHeaderView.nibName)
        headerView.titleLabel.textColor = HexColor("5f5f5f")!
        headerView.titleLabel.text = [LocalizableString.Passions, LocalizableString.Details, LocalizableString.MutualFriends][section - 1].localizedString.uppercased()
        return headerView
    }
}

// MARK: - InvitedByCellDelegate
extension OtherPersonAboutViewController: InvitedByCellDelegate {
    
    func onInvitedByCellClicked(cell: OtherPersonAboutInvitedByTableViewCell) {
        
        if user.invitedByUserId! == UserProvider.shared.currentUser?.objectId {
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            
            Helper.currentTabNavigationController()?.pushViewController(profileController, animated: true)
        } else { // other person profile
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.userId = user.invitedByUserId!
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
}

// MARK: - OtherPersonAboutInviteCellDelegate
extension OtherPersonAboutViewController: OtherPersonAboutInviteCellDelegate {
    
    func inviteCell(cell: OtherPersonAboutInviteTableViewCell, didClickedOnInvite button: UIButton) {
        let inviteFriendView: InviteFriendsView = InviteFriendsView.loadFromNib()
        inviteFriendView.present(on: Helper.initialNavigationController().view)
    }
}

