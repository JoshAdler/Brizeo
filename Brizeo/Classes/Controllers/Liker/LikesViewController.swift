//
//  LikesViewController.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD
import ChameleonFramework
import SDWebImage

class LikesViewController: BasicViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let rowHeight: CGFloat = 88.0
        static let headerViewHeight: CGFloat = 53.0
        static let headerViewColor = HexColor("ebebeb")
    }
    
    struct StoryboardIds {
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var likesTableView: UITableView!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var users = [User]()
    var moment: Moment!
    var currentUser = UserProvider.shared.currentUser!
    var topRefresher: UIRefreshControl!
    var event: Event?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(LikesViewController.refreshTableView), for: .valueChanged)
        likesTableView.addSubview(topRefresher)
        likesTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        if isEventAvailable() {
            loadEventAttendings()
        } else {
            loadLikers()
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func isEventAvailable() -> Bool {
        return event != nil
    }
    
    @objc fileprivate func refreshTableView() {
        if isEventAvailable() {
            loadEventAttendings()
        } else {
            loadLikers()
        }
    }
    
    fileprivate func loadEventAttendings() {
        
        guard let ids = event!.attendingsIds else {
            
            self.users = []
            self.likesTableView.reloadData()
            return
        }
        
        UserProvider.loadFacebookUsers(with: ids) { (result) in
            
            switch result {
            case .success(let users):
                self.users = users
                self.likesTableView.reloadData()
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            default:
                break
            }
            
            self.topRefresher.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.likesTableView.isHidden = false
        }
    }
    
    fileprivate func loadLikers() {
        MomentsProvider.getLikers(for: moment) { (result) in
            switch result {
            case .success(let users):
                self.users = users
                self.likesTableView.reloadData()
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            default:
                break
            }
            
            self.topRefresher.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.likesTableView.isHidden = false
        }
    }
}

//MARK: - UITableViewDataSource
extension LikesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        let cell: LikesTableViewCell = tableView.dequeueCell(withIdentifier: LikesTableViewCell.identifier, for: indexPath)
        
        cell.delegate = self
        cell.titleLabel.text = user.isCurrent ? "You" : user.shortName/*displayName*/
        
        if user.hasProfileImage {
            cell.profileLogoImageView.sd_setImage(with: user.profileUrl!)
        } else {
            cell.profileLogoImageView.image = nil
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LikesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        if user.objectId == currentUser.objectId { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            
            Helper.currentTabNavigationController()?.pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
            
            if isEventAvailable() {
                LocalyticsProvider.userGoProfileFromEventAttendings()
            } else {
                LocalyticsProvider.userGoProfileFromLikers()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // header view
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: Constants.headerViewHeight))
        viewHeader.translatesAutoresizingMaskIntoConstraints = true
        viewHeader.backgroundColor = Constants.headerViewColor
        
        // title label
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: Constants.headerViewHeight))
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.text = isEventAvailable() ? LocalizableString.EventsAttendingsHeaderTitle.localizedString : LocalizableString.LikersHeaderTitle.localizedString
        lblTitle.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0)
        lblTitle.textAlignment = .center
        lblTitle.textColor = HexColor("5f5f5f")
        viewHeader.addSubview(lblTitle)
        
        return viewHeader
    }
}

// MARK: - LikesTableViewCellDelegate
extension LikesViewController: LikesTableViewCellDelegate {
    
    func likesCell(cell: LikesTableViewCell, didClickedProfile button: UIButton) {
        
        //TODO: just in case something will be changed
        guard let indexPath = likesTableView.indexPath(for: cell) else {
            return
        }
        
        let user = users[indexPath.row]
        if user.objectId == currentUser.objectId { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            
            Helper.currentTabNavigationController()?.pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            
            Helper.currentTabNavigationController()?.pushViewController(otherPersonProfileController, animated: true)
        }
    }
}
