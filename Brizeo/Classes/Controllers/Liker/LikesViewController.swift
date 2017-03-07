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
        static let rowHeight: CGFloat = 80.0
        static let headerViewHeight: CGFloat = 50.0
        static let headerViewColor = HexColor("dedede")
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
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(LikesViewController.refreshTableView), for: .valueChanged)
        likesTableView.addSubview(topRefresher)
        
        self.title = LocalizableString.LikesTitle.localizedString
    
        likesTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadLikers()
    }
    
    // MARK: - Private methods
    
    @objc fileprivate func refreshTableView() {
        loadLikers()
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
        cell.titleLabel.text = user.displayName
        
        if user.hasProfileImage {
            cell.profileLogoImageView.sd_setImage(with: user.profileUrl!)
        } else {
            cell.profileLogoImageView.image = nil
        }
        
        cell.likesView.isHidden = user.objectId == currentUser.objectId
        cell.likesView.isMatched = false
        
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
            
            Helper.initialNavigationController().pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            
            Helper.initialNavigationController().pushViewController(otherPersonProfileController, animated: true)
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
        lblTitle.text = "Click Avatar to View Profile"
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.black
        viewHeader.addSubview(lblTitle)
        
        return viewHeader
    }
}

// MARK: - LikesTableViewCellDelegate
extension LikesViewController: LikesTableViewCellDelegate {
    
    func likesCell(cell: LikesTableViewCell, didClickedApprove likerView: LikerView) {
        showBlackLoader()
        
        guard let indexPath = likesTableView.indexPath(for: cell) else {
            print("No index path for liker user")
            return
        }
        let user = users[indexPath.row]
        
        MatchesProvider.approveMatch(for: user) { (result) in
            self.hideLoader()
            
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
            default:
                break
            }
        }
    }
    
    func likesCell(cell: LikesTableViewCell, didClickedDecline likerView: LikerView) {
        showBlackLoader()
        
        guard let indexPath = likesTableView.indexPath(for: cell) else {
            print("No index path for liker user")
            return
        }
        let user = users[indexPath.row]
        
        MatchesProvider.declineMatch(for: user) { (result) in
            self.hideLoader()
            
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error.localizedDescription, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
            default:
                break
            }
        }
    }
}
