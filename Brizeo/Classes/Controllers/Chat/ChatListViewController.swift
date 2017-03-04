//
//  ChatListViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

class ChatListViewController: UIViewController {//ATLConversationListViewController {

//    // MARK: - Types
//    
//    struct StoryboardIds {
//        static let chatControllerId = "ChatViewController"
//    }
//    
//    // MARK: - Properties
//    
//    fileprivate var currentUser: User!
//    fileprivate var matches = [User]()
//    fileprivate var paginator = PaginationHelper(pagesSize: 100)
//    
//    // MARK: - Controller lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        currentUser = User.test()
//        
//        self.title = nil
//        self.accessibilityLabel = nil
//        
//        layerClient = LayerManager.sharedManager.layerClient
//        
//        shouldDisplaySearchController = true
//        
//        cellClass = ATLConversationTableViewCell.self
//        allowsEditing = true
//        displaysAvatarItem = true
//        rowHeight = 76.0
//        shouldDisplaySearchController = true
//        deletionModes = [NSNumber(value: LYRDeletionMode.myDevices.rawValue as UInt)]
//        
//        // new code from Applozic
//        let chatManager : ALChatManager = ALChatManager(applicationKey: Configurations.Applozic.appKey as NSString)
//        chatManager.registerUserAndLaunchChat(ALChatManager.getUserDetail(), fromController: self, forUser:nil)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarItem.badgeValue = nil
//        
//        self.matches = [User]()
//        
//        for mode in 0...15{
//            MatchesProvider.getUserMatchesAlt(currentUser.objectId!, mode: mode) { (result) in
//                switch result {
//                case .success(let matches):
//                    self.matches += matches
//                    
//                    print(matches)
//                    print(self.matches.count)
//                case .failure(let error):
//                    SVProgressHUD.showError(withStatus: error)
//                }
//                
//                self.tableView.reloadData()
//            }
//        }
//    }
//}
//
////MARK: - ATLConversationListViewControllerDataSource
//extension ChatListViewController: ATLConversationListViewControllerDataSource {
//    
//    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, avatarItemFor conversation: LYRConversation) -> ATLAvatarItem {
//        
//        let participantEntity = conversation.participants.filter { $0.userID != currentUser.objectId }.first
//        
//        if let participantEntity = participantEntity {
//            
//            let participant = matches.filter { $0.objectId == participantEntity.userID }.first
//            
//            if let participant = participant {
//                
//                return participant
//            }
//            
//            return participantEntity
//        }
//        return currentUser
//    }
//    
//    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, titleFor conversation: LYRConversation) -> String {
//        
//        let participantEntity = conversation.participants.filter { $0.userID != currentUser.objectId }.first
//        
//        if let participantEntity = participantEntity {
//            
//            let participant = matches.filter { $0.objectId == participantEntity.userID }.first
//            
//            if let participant = participant {
//                
//                return participant.displayName
//            }
//        }
//        
//        return " "
//    }
//    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let conversation = self.queryController?.object(at: indexPath)
//        if let conversation = conversation as? LYRConversation {
//            
//            let participantEntity = conversation.participants.filter { $0.userID != currentUser.objectId }.first
//            
//            if let participantEntity = participantEntity {
//                
//                let participant = matches.filter { $0.objectId == participantEntity.userID }.first
//                
//                if let participant = participant , participant.superUser {
//                    
//                    return false
//                }
//            }
//        }
//        
//        return true
//    }
//    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        var actions = [UITableViewRowAction]()
//        
//        let deleteAction = UITableViewRowAction(style: .destructive, title: LocalizableString.Block.localizedString) { (action, indexPath) in
//            
//            let conversation = self.queryController?.object(at: indexPath)
//            if let conversation = conversation as? LYRConversation {
//                
//                let participantEntity = conversation.participants.filter { $0.userID != self.currentUser.objectId }.first
//                if let participantEntity = participantEntity {
//                    
//                    let participant = self.matches.filter { $0.objectId == participantEntity.userID }.first
//                    if let participant = participant {
//                        
//                        self.showBlackLoader()
//                        UserProvider.removeMatch(self.currentUser, target: participant, completion: { (result) in
//                            
//                            self.hideLoader()
//                            switch result {
//                            case .success(_):
//                                
//                                var error: NSError?
//                                let success = conversation.delete(LYRDeletionMode.allParticipants, error: &error)
//                                
//                                if success {
//                                    SVProgressHUD.showSuccess(withStatus: LocalizableString.Success.localizedString)
//                                } else {
//                                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
//                                }
//                                break
//                            case .failure(let message):
//                                self.showAlert(LocalizableString.Error.localizedString, message: message, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                            }
//                        })
//                    }
//                }
//            }
//        }
//        
//        let reportAction = UITableViewRowAction(style: .normal, title: LocalizableString.Report.localizedString) { (action, indexPath) in
//            
//            let conversation = self.queryController?.object(at: indexPath)
//            
//            if let conversation = conversation as? LYRConversation {
//                
//                let participantEntity = conversation.participants.filter { $0.userID != self.currentUser.objectId }.first
//                if let participantEntity = participantEntity {
//                    
//                    let participant = self.matches.filter { $0.objectId == participantEntity.userID }.first
//                    if let participant = participant {
//                        
//                        self.showBlackLoader()
//                        UserProvider.reportUser(participant, user: self.currentUser, completion: { (result) in
//                            
//                            self.hideLoader()
//                            switch result {
//                                
//                            case .success(_):
//                                self.showAlert("", message: LocalizableString.UserHadBeenReported.localizedString, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                                break
//                            case .failure(let error):
//                                self.showAlert(LocalizableString.Error.localizedString, message: error, dismissTitle: LocalizableString.Ok.localizedString, completion: nil)
//                            }
//                        })
//                    }
//                }
//            }
//        }
//        
//        actions.append(deleteAction)
//        actions.append(reportAction)
//        
//        return actions
//    }
//}
//
////MARK: - ATLConversationListViewControllerDelegate
//extension ChatListViewController: ATLConversationListViewControllerDelegate {
//    
//    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, didSelect conversation: LYRConversation) {
//        
//        let chatController: ChatViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.chatControllerId)!
//        chatController.conversation = conversation
//        
//        Helper.initialNavigationController().pushViewController(chatController, animated: true)
//    
//        searchController.searchBar.text = nil
//        searchController.isActive = false
//    }
//    
//    func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, didDelete conversation: LYRConversation, deletionMode: LYRDeletionMode) {
//        
//        do {
//            var error: NSError?
//            let participants = Set(arrayLiteral: currentUser.objectId!)
//            try conversation.removeParticipants(participants)
//            let success = conversation.delete(deletionMode, error: &error)
//            
//            if success {
//                SVProgressHUD.showSuccess(withStatus: LocalizableString.Success.localizedString)
//            } else {
//                SVProgressHUD.showError(withStatus: error?.localizedDescription)
//            }
//        } catch {
//            SVProgressHUD.showError(withStatus: LocalizableString.DeleteChatError.localizedString)
//        }
//    }
//    
//    private func conversationListViewController(_ conversationListViewController: ATLConversationListViewController, didSearchForText searchText: String, completion: (Set<NSObject>) -> Void) {
//        
//        let filtered = matches.filter { $0.displayName.contains(searchText) }
//        completion(Set(filtered))
//    }
}
