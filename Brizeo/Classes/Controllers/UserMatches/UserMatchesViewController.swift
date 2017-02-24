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

class UserMatchesViewController: UIViewController {

    // MARK: - Types
    
    struct Constants {
        static let blueColor = HexColor("408FDC")
    }
    
    struct StoryboardIds {
        static let otherProfileController = "OtherProfileViewController"
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
    
    fileprivate var matches = [User]()
    fileprivate var paginator = PaginationHelper(pagesSize: 100)
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addInfiniteScroll { [unowned self] (tableView) in
            self.paginator.increaseCurrentPage()
            self.loadMatches()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMatches()
    }
    
    // MARK: - Public methods
    
    func loadMatches() {
        MatchesProvider.getUserMatches(user.objectId!, paginater: paginator) { (result) in
            switch result {
            case .success(let value):
                self.paginator.addNewElements(&self.matches, newElements: value)
                self.matches.append(User.test())
                self.tableView.reloadData()
                break
            case .failure(let error):
                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
                break
            }
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func rightUtilsButtons() -> [AnyObject] {
        let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: UIColor.blue, title: LocalizableString.Chat.localizedString)
        return rightUtilityButtons as [AnyObject]
    }
    
    fileprivate func resetMoments() {
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
        if let url = user.profileImageUrl {
            cell.avatarImageView.sd_setImage(with: url)
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
        
        let profileController: OtherProfileViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.otherProfileController)!
        Helper.initialNavigationController().pushViewController(profileController, animated: true)
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
            
//            if let conversation = LayerManager.conversationBetweenUser(User.current()!.objectId!, andUserId: user.objectId!, message: nil) {
//                
//                let chatController: ChatViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.chatController)!
//                navigationController?.pushViewController(chatController, animated: true)
//            }
            tableView.endEditing(true)
        }
    }
}
