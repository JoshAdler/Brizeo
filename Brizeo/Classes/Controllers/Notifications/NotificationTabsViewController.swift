//
//  NotificationTabsViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/27/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import CarbonKit
import SVProgressHUD

class NotificationTabsViewController: BasicViewController {
    
    // MARK: - Types
    
    struct Constants {
        static let titles = [LocalizableString.LikesTitle.localizedString.capitalized, LocalizableString.People.localizedString.capitalized]
        static let notificationsControllerId = "NotificationsViewController"
    }
    
    // MARK: - Properties
    
    var likesController: NotificationsViewController!
    var peopleController: NotificationsViewController!
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load controller
        likesController = Helper.controllerFromStoryboard(controllerId: Constants.notificationsControllerId)!
        likesController.contentType = .momentsLikes
        likesController.delegate = self
        
        peopleController = Helper.controllerFromStoryboard(controllerId: Constants.notificationsControllerId)!
        peopleController.delegate = self
        
        carbonTabSwipeNavigation = Helper.createCarbonController(with: Constants.titles, self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.pagesScrollView?.isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotifications(notification:)), name: NSNotification.Name(rawValue: shouldReloadNotifications), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationsBadgeNumbers(notification:)), name: NSNotification.Name(rawValue: notificationsBadgeNumberWasChanged), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        LocalyticsProvider.userViewNotifications()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public methods
    
    func reloadNotifications(notification: NSNotification) {
        
        if let dict = notification.userInfo as? [String: Any], let type = dict["type"] as? NotificationType {
            if type == .momentsLikes && likesController.isViewLoaded {
                likesController.reloadContent()
            } else if type == .newMatches && peopleController.isViewLoaded {
                peopleController.reloadContent()
            }
        }
    }
    
    func updateNotificationsBadgeNumbers(notification: NSNotification) {
        
        guard let info = notification.userInfo else {
            return
        }
        
        if let likesNumber = info["likesNumber"] as? Int {
            let likesNumberStr = likesNumber == 0 ? nil : "\(likesNumber)"
            let likesTitle = "Likes" + ((likesNumberStr != nil) ? " (\(likesNumberStr!))" : "")

            (carbonTabSwipeNavigation.carbonSegmentedControl!).setTitle(likesTitle, forSegmentAt: 0)
        }
        
        if let peopleNumber = info["peopleNumber"] as? Int {
            let peopleNumberStr = peopleNumber == 0 ? nil : "\(peopleNumber)"
            
            let likesTitle = "People" + ((peopleNumberStr != nil) ? " (\(peopleNumberStr!))" : "")
            
            (carbonTabSwipeNavigation.carbonSegmentedControl!).setTitle(likesTitle, forSegmentAt: 1)
        }
        
        if let needToDecreaseLikesNumber = info["decreaseNotificationNumber"] as? Bool {
            
            if needToDecreaseLikesNumber { // decrease likes number
                
                let title = (carbonTabSwipeNavigation.carbonSegmentedControl!).titleForSegment(at: 0)!
                var components = title.components(separatedBy: "(")
                if components.count > 1 {
                    var currentNumberString = components[1]
                    currentNumberString.remove(at: currentNumberString.index(before: currentNumberString.endIndex))
                    let currentNumber = (Int(currentNumberString) ?? 0) - 1
                    let likesTitle = "Likes" + ((currentNumber > 0) ? " (\(currentNumber))" : "")
                    
                    (carbonTabSwipeNavigation.carbonSegmentedControl!).setTitle(likesTitle, forSegmentAt: 0)
                }
            } else { // decrease people number
                
                let title = (carbonTabSwipeNavigation.carbonSegmentedControl!).titleForSegment(at: 1)!
                var components = title.components(separatedBy: "(")
                if components.count > 1 {
                    var currentNumberString = components[1]
                    currentNumberString.remove(at: currentNumberString.index(before: currentNumberString.endIndex))
                    let currentNumber = (Int(currentNumberString) ?? 0) - 1
                    let likesTitle = "People" + ((currentNumber > 0) ? " (\(currentNumber))" : "")
                    
                    (carbonTabSwipeNavigation.carbonSegmentedControl!).setTitle(likesTitle, forSegmentAt: 1)
                }
            }
        }
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension NotificationTabsViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return likesController
        } else {
            return peopleController
        }
    }
}

// MARK: - NotificationsViewControllerDelegate
extension NotificationTabsViewController: NotificationsViewControllerDelegate {
    
    func loadNotifications(for type: NotificationType?, _ withLoading: Bool, completionHandler: @escaping ([Notification]?) -> Void) {
        
        if withLoading {
            showBlackLoader()
        }
        
        NotificationProvider.getNotification(for: UserProvider.shared.currentUser!.objectId) { (result) in
            
            if withLoading {
                self.hideLoader()
            }
            
            switch result {
            case .success(let notifications):
                
                if type == nil { // all matches types
                    let filteredNotifications = notifications.filter({ $0.pushType != NotificationType.momentsLikes }).sorted(by: { (leftNot, rightNot) -> Bool in
                        
                        let leftDate = leftNot.createDate
                        let rightDate = rightNot.createDate
                        
                        if leftDate == nil && rightDate == nil {
                            return true
                        } else if leftDate != nil && rightDate != nil {
                            return leftDate! > rightDate!
                        } else if leftDate != nil {
                            return true
                        } else {
                            return false
                        }
                    })
                    completionHandler(filteredNotifications)
                } else {
                    let filteredNotifications = notifications.filter({ $0.pushType == type }).sorted(by: { (leftNot, rightNot) -> Bool in
                        
                        let leftDate = leftNot.createDate
                        let rightDate = rightNot.createDate
                        
                        if leftDate == nil && rightDate == nil {
                            return true
                        } else if leftDate != nil && rightDate != nil {
                            return leftDate! > rightDate!
                        } else if leftDate != nil {
                            return true
                        } else {
                            return false
                        }
                    })
                    completionHandler(filteredNotifications)
                }
                
                let unreadNotifications = notifications.filter({ return !$0.isAlreadyViewed })
                let likesNotifications = unreadNotifications.filter({ $0.pushType == .momentsLikes })
                
                Helper.sendNotification(with: notificationsBadgeNumberWasChanged, object: nil, dict: [
                    "number": unreadNotifications.count,
                    "likesNumber": likesNotifications.count,
                    "peopleNumber": unreadNotifications.count - likesNotifications.count
                    ])
                
            case .failure(let error):
                
                if withLoading {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                
                completionHandler(nil)
            default:
                break
            }
        }
    }
}
