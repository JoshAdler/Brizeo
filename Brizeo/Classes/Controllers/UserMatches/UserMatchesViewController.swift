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
import Typist

class UserMatchesViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let blueColor = HexColor("408FDC")
        static let searchBarHeight: CGFloat = 45.0
    }
    
    struct StoryboardIds {
        static let otherProfileControllerId = "OtherProfileViewController"
        static let profileControllerId = "PersonalTabsViewController"
        static let chatController = "ChatViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var customSearchBar: CustomSearchBar! {
        didSet {
            customSearchBar.placeholder = LocalizableString.Search.localizedString
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = LocalizableString.SwipeLeftToChat.localizedString
        }
    }
    
    var user : User!
    
    fileprivate var topRefresher: UIRefreshControl!
    fileprivate var matches = [User]()
    fileprivate var paginator = PaginationHelper(pagesSize: 100)
    fileprivate var filteredUsers: [User]?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set top refresher
        topRefresher = UIRefreshControl()
        topRefresher.addTarget(self, action: #selector(UserMatchesViewController.resetMatches), for: .valueChanged)
        tableView.addSubview(topRefresher)
        
        configureKeyboardBehaviour()
        
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
                    welf.filterContentForSearchText(searchText: "")
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
                
                welf.topRefresher.endRefreshing()
            }
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func configureKeyboardBehaviour() {
        let keyboard = Typist.shared
        
        keyboard
            .on(event: .willHide, do: { (options) in
                self.tableViewBottomConstraint.constant = 0
            })
            .on(event: .willShow, do: { (options) in
                self.tableViewBottomConstraint.constant = options.endFrame.height
            })
            .start()
    }
    
    fileprivate func filterContentForSearchText(searchText: String) {
        if searchText.numberOfCharactersWithoutSpaces() == 0 {
            filteredUsers = matches
        } else {
            filteredUsers = matches.filter {
                $0.displayName.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
    
    fileprivate func rightUtilsButtons() -> [AnyObject] {
        let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: .clear, icon: #imageLiteral(resourceName: "ic_delete_button_matches"))
        rightUtilityButtons.sw_addUtilityButton(with: .clear, icon: #imageLiteral(resourceName: "ic_chat_button_matches"))
        return rightUtilityButtons as [AnyObject]
    }
    
    fileprivate func hideSearchBar() {
        customSearchBar?.endEditing(true)
        customSearchBar?.showsCancelButton = false
        customSearchBar?.setNeedsDisplay()
        customSearchBar?.text = nil
        filterContentForSearchText(searchText: "")
    }
    
    fileprivate func declineUser(user: User) {
        showBlackLoader()
        
        MatchesProvider.declineMatch(for: user) { [weak self] (result) in
            
            if let welf = self {
                
                switch(result) {
                case .success(_):
                    
                    welf.hideLoader()
                    
                    if let index = welf.matches.index(where: { $0.objectId == user.objectId }) {
                        welf.matches.remove(at: index)
                    }
                    
                    welf.filterContentForSearchText(searchText: welf.customSearchBar.text ?? "")
                    
                    break
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    break
                default: break
                }
            }
        }
    }
    
    @objc fileprivate func resetMatches() {
        paginator.resetPages()
        loadMatches()
    }
}

// MARK: - UITableViewDataSource
extension UserMatchesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        let user = filteredUsers![indexPath.row]
    
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
        return 57.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = matches[indexPath.row]
        
        if user.isCurrent { // show my profile
            let profileController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.profileControllerId)!
            navigationController?.pushViewController(profileController, animated: true)
        } else {
            let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
            otherPersonProfileController.user = user
            navigationController?.pushViewController(otherPersonProfileController, animated: true)
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
            
            let user = self.filteredUsers![indexPath.row]
            
            // show confirmation
            let confirmationView: ConfirmationView = ConfirmationView.loadFromNib()
            confirmationView.present(on: Helper.initialNavigationController().view, confirmAction: {
                self.declineUser(user: user)
            }, declineAction: nil)
            tableView.endEditing(true)
        }else if index == 1 { // chat
            
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            let user = self.filteredUsers![indexPath.row]
            
            ChatProvider.startChat(with: user.objectId, from: self)
            tableView.endEditing(true)
            tableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate
extension UserMatchesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        filterContentForSearchText(searchText: searchBar.text!)
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchBar.text!)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
}
