//
//  OtherPersonAboutViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/1/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

let mutualFriendsNotification = "mutualFriendsNotification"

class OtherPersonAboutViewController: UIViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let inviteCellHeightCoef: CGFloat = 110.0 / 985.0
        static let infoCellHeightCoef: CGFloat = 234.0 / 985.0
        static let invitedByCellHeightCoef: CGFloat = 74.0 / 985.0
        static let headerViewHeightCoef: CGFloat = 74.0 / 985.0
    }
    
    struct StoryboardIds {
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var passionsTableView: UITableView!
    
    var mutualFriends: [(String, String)]?
    var user: User!
    var locationString: String?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerHeaderViews()
        
        if mutualFriends == nil {
            fetchMutualFriends()
        }
        
        // load user location
        user.getUserLocationString { (location) in
            self.locationString = location
            self.passionsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onSaveButtonClicked(_ sender: UIButton!) {
        
    }
    
    // MARK: - Private methods
    
    fileprivate func registerHeaderViews() {
        passionsTableView.register(UINib(nibName: SettingsBigHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SettingsBigHeaderView.nibName)
    }
    
    fileprivate func fetchMutualFriends() {
        UserProvider.getMutualFriendsOfCurrentUser(/*User.current()!*/User.test(), andSecondUser: user, completion: { (result) in
            switch result {
            case .success(let value):
                // send notification
                let notification = UIKit.Notification(name: NSNotification.Name.init(rawValue: mutualFriendsNotification), object: nil, userInfo: ["mutualFriends": value, "userId": self.user?.userID])
                NotificationCenter.default.post(notification)
                
                self.mutualFriends = value
                self.passionsTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Dismiss.localizedString, completion: nil)
            }
        })
    }
}

// MARK: - UITableViewDataSource
extension OtherPersonAboutViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { // details
            return user.hasInvitedByPerson ? 2 : 1 /* details with/out invited by */
        }
        
        if section == 2 { // mutual friends
            return mutualFriends?.count ?? 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // text cell
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutTextTableViewCell.identifier, for: indexPath) as! OtherPersonAboutTextTableViewCell
            cell.titleLabel.text = user.personalText
            return cell
        } else if indexPath.section == 1 { // info cell
            if indexPath.row == 0 { // detail cell
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutInfoTableViewCell.identifier, for: indexPath) as! OtherPersonAboutInfoTableViewCell
                
                cell.applyUser(user: user)
                cell.applyLocationWithUser(user: user, locationString: locationString)
                cell.friendsLabel.text = "\(mutualFriends?.count ?? 0) mutual friends"
                
                return cell
            } else { // invited by
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutInvitedByTableViewCell.identifier, for: indexPath) as! OtherPersonAboutInvitedByTableViewCell
                
                cell.delegate = self
                cell.invitedByName = "Roger"
                
                return cell
            }
        } else { // invite cell
            let cell = tableView.dequeueReusableCell(withIdentifier: OtherPersonAboutInviteTableViewCell.identifier, for: indexPath) as! OtherPersonAboutInviteTableViewCell
//            cell.logoImageView.sd_setImage(with: mutualFriends![indexPath.row].0)
            cell.titleLabel.text = mutualFriends![indexPath.row].1
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension OtherPersonAboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { // text cell
            return UITableViewAutomaticDimension
        } else if indexPath.section == 1 { // info cell
            if indexPath.row == 0 { // details
                return tableView.bounds.height * Constants.infoCellHeightCoef
            } else { // invited by
                return tableView.bounds.height * Constants.invitedByCellHeightCoef
            }
        } else {
            return tableView.bounds.height * Constants.inviteCellHeightCoef
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return tableView.bounds.height * Constants.headerViewHeightCoef
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let headerView: SettingsBigHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsBigHeaderView.nibName)
        headerView.titleLabel.text = [LocalizableString.Details, LocalizableString.MutualFriends][section - 1].localizedString.uppercased()
        return headerView
    }
}

// MARK: - InvitedByCellDelegate
extension OtherPersonAboutViewController: InvitedByCellDelegate {
    
    func onInvitedByCellClicked(cell: OtherPersonAboutInvitedByTableViewCell) {
        // push user profile
        if true {//User.userIsCurrentUser(user.invited) { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            Helper.initialNavigationController().pushViewController(profileController, animated: true)
        } else { // other person profile
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            Helper.initialNavigationController().pushViewController(otherPersonProfileController, animated: true)
        }
    }
}

