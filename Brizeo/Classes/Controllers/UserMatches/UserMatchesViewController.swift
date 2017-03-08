//
//  MyMatchesViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import ChameleonFramework
import SWTableViewCell
import SDWebImage
import SVProgressHUD

class UserMatchesViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let blueColor = HexColor("408FDC")
    }
    
    struct StoryboardIds {
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let chatController = "ChatViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = LocalizableString.SwipeLeftToChat.localizedString
        }
    }
    
    var user : User!
    
    fileprivate var topRefresher: UIRefreshControl!
    fileprivate var matches = [User]()
    fileprivate var paginator = PaginationHelper(pagesSize: 100)
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(UserMatchesViewController.resetMatches), for: .valueChanged)
        tableView.addSubview(topRefresher)
        
//        tableView.addInfiniteScroll { [unowned self] (tableView) in
//            self.paginator.increaseCurrentPage()
//            self.loadMatches()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if matches.count == 0 {
            loadMatches()
        }
    }
    
    // MARK: - Public methods
    
    func loadMatches() {
        MatchesProvider.getMatches(for: user) { [weak self] (result) in
            
            if let welf = self {
                switch(result) {
                case .success(let users):
                    welf.matches = users
                    //                self.paginator.addNewElements(&self.matches, newElements: value)
                    welf.tableView.reloadData()
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func rightUtilsButtons() -> [AnyObject] {
        let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: UIColor.blue, title: LocalizableString.Chat.localizedString)
        return rightUtilityButtons as [AnyObject]
    }
    
    @objc fileprivate func resetMatches() {
        paginator.resetPages()
        loadMatches()
    }
}

// MARK: - UITableViewDataSource
extension UserMatchesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        let user = matches[indexPath.row]
    
        cell.delegate = self
        cell.rightUtilityButtons = rightUtilsButtons()
        cell.nameLabel.text = user.displayName
        
        if user.hasProfileImage {
            cell.avatarImageView.sd_setImage(with: user.profileUrl)
        } else {
            cell.avatarImageView.image = nil
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserMatchesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = matches[indexPath.row]
        
        if user.isCurrent { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            Helper.initialNavigationController().pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            Helper.initialNavigationController().pushViewController(otherPersonProfileController, animated: true)
        }
    }
}

// MARK: - SWTableViewCellDelegate
extension UserMatchesViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        
        if index == 0 {
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            let user = self.matches[indexPath.row]
            ChatProvider.startChat(with: user.objectId, from: self)
            tableView.endEditing(true)
        }
    }
}
