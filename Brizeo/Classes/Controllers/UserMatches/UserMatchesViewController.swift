//
//  MyMatchesViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/30/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Alamofire
import ChameleonFramework
import SWTableViewCell
import SDWebImage
import SVProgressHUD
import Typist
import Applozic

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
    var isSelected = false
    
    fileprivate var topRefresher: UIRefreshControl!
    fileprivate var matches = [User]()
    fileprivate var paginator = PaginationHelper(pagesSize: 100)
    fileprivate var filteredUsers: [User]?
    fileprivate var keyboardTypist: Typist!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureKeyboardBehaviour()
        
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
        
        topRefresher.endRefreshing()
        
        if matches.count == 0 {
            loadMatches()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let charNavController = Helper.currentTabNavigationController()?.presentedViewController as? UINavigationController, let chatController = charNavController.viewControllers[0] as? ALChatViewController {
            chatController.shouldOpenProfile = false
        }
    }
    
    // MARK: - Public methods
    
    func loadMatches() {
        MatchesProvider.getMatches(for: user) { [weak self] (result) in
            
            if let welf = self {
                switch(result) {
                case .success(let users):
                    let superUser = users.filter({ return $0.isSuperUser })
                    let restUsers = users.filter({ return !$0.isSuperUser }).sorted(by: { return $0.displayName < $1.displayName })
                    
                    var allUsers = [User]()
                    
                    allUsers.append(contentsOf: superUser)
                    allUsers.append(contentsOf: restUsers)
                    
                    welf.matches = allUsers
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
        keyboardTypist = Typist()
        
        keyboardTypist
            .on(event: .willHide, do: { (options) in
                
                if !self.isSelected {
                    return
                }
                
                print("Will hide on matches")
                self.tableViewBottomConstraint.constant = 0
            })
            .on(event: .willShow, do: { (options) in
                
                if !self.isSelected {
                    return
                }
                
                print("Will show on matches")
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
    
    fileprivate func rightUtilsButtons(for user: User) -> [AnyObject] {
        let rightUtilityButtons = NSMutableArray()
        
        if !user.isSuperUser {
            rightUtilityButtons.sw_addUtilityButton(with: .clear, icon: #imageLiteral(resourceName: "ic_delete_button_matches"))
        }
        
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
                    
                    // remove chat with this person
                    ChatProvider.removeConversation(with: user)
                    
                    if let index = welf.matches.index(where: { $0.objectId == user.objectId }) {
                        welf.matches.remove(at: index)
                    }
                    
                    LocalyticsProvider.trackUnMatchPerson()
                    
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
    
    fileprivate func startChat(with user: User) {
        
        ChatProvider.startChat(with: user.objectId, from: Helper.initialNavigationController())
        tableView.endEditing(true)
        tableView.reloadData()
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
        cell.rightUtilityButtons = rightUtilsButtons(for: user)
        cell.nameLabel.text = user.shortName/*displayName*/
        
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
        
        let user = (filteredUsers ?? matches)[indexPath.row]
        let otherPersonProfileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileControllerId)!
        
        otherPersonProfileController.user = user
        
        let navigation = navigationController ?? Helper.currentTabNavigationController()
        navigation?.pushViewController(otherPersonProfileController, animated: true)
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
            
            // start chat for superuser
            if user.isSuperUser {
                startChat(with: user)
                return
            }
            
            // show confirmation
            let confirmationView: ConfirmationView = ConfirmationView.loadFromNib()
            confirmationView.present(on: Helper.initialNavigationController().view, confirmAction: {
                self.declineUser(user: user)
            }, declineAction: nil)
            tableView.endEditing(true)
        } else if index == 1 { // chat
            
            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            let user = self.filteredUsers![indexPath.row]
            startChat(with: user)
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
