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
        static let profileControllerId = "OtherProfileViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var likesTableView: UITableView!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var users = [User]()
    var moment: Moment!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizableString.LikesTitle.localizedString
    
        likesTableView.tableFooterView = UIView()

        MomentsProvider.getUsersWhoLikedMoment(moment) { [unowned self] (result) in
            switch result {
            case .success(let users):
                self.users = users
                self.likesTableView.reloadData()
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error)
            default:
                break
            }
            
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
        
        cell.likesView.isMatched = false
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LikesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        let profileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
        profileController.user = user
        
        Helper.initialNavigationController().pushViewController(profileController, animated: true)
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
        
    }
    
    func likesCell(cell: LikesTableViewCell, didClickedDecline likerView: LikerView) {
        
    }
}
