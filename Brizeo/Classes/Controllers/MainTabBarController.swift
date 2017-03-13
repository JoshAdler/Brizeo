//
//  MainTabBarController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/26/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Applozic

class MainTabBarController: UITabBarController {
    
    // MARK: - Types
    
    struct StoryboardIds {
        static let personalTabsController = "PersonalTabsViewController"
    }
    
    struct Constants {
        static let logoHeight: CGFloat = 25.0
    }
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if let items = tabBar.items {
            for item in items {
                item.image = item.image!.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage!.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = navigationController {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizableString.Back.localizedString, style: .plain, target: nil, action: nil)
            
            if navigationController.viewControllers.count < 3 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_search").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onRightButtonClicked(sender:)))
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_settings").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onLeftButtonClicked(sender:)))
                navigationItem.leftBarButtonItem?.width = #imageLiteral(resourceName: "ic_search").size.width
            }
        }
        
        showLogoIfNeeds()
    }
    
    // MARK: - Public methods
    
    func shouldShowLogo() -> Bool {
        return true
    }
    
    // MARK: - Private methods
    
    fileprivate func showLogoIfNeeds() {
        if !shouldShowLogo() { return }
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_nav_logo"))
        imageView.contentMode = .scaleAspectFit
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        navigationItem.titleView = titleView
    }
    
    // MARK: - Actions
    
    func onLeftButtonClicked(sender: UIBarButtonItem) {
        let personalController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.personalTabsController)!
        navigationController?.pushViewController(personalController, animated: true)
    }
    
    func onRightButtonClicked(sender: UIBarButtonItem) {
        let inviteFriendView: InviteFriendsView = InviteFriendsView.loadFromNib()
        inviteFriendView.present(on: navigationController!.view)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: ChatListViewController.self) {
            ChatProvider.startChat(with: nil, from: self)
            
            return false
        }
        return true
    }
}
