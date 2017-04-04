//
//  ChatListViewController.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/31/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import SVProgressHUD
import Applozic

class ChatListViewController: ALSubViewController {//BasicViewController {

    // MARK: - Types
    
    struct StoryboardIds {
        static let personalTabsController = "PersonalTabsViewController"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // place title view
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_nav_logo"))
        imageView.contentMode = .scaleAspectFit
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        navigationItem.titleView = titleView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = navigationController {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizableString.Back.localizedString, style: .plain, target: nil, action: nil)
            
            if navigationController.viewControllers.count < 2 {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_settings").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onLeftButtonClicked(sender:)))
                navigationItem.leftBarButtonItem?.width = #imageLiteral(resourceName: "ic_search").size.width
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_search").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onRightButtonClicked(sender:)))
        }
        
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        let storyboard = UIStoryboard(name: "Applozic", bundle: Bundle(for: ALChatViewController.self))
        msgView = storyboard.instantiateViewController(withIdentifier: "ALViewController") as? ALMessagesViewController
        
        showViewControllerInContainerView(msgView)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public methods
    
    func onLeftButtonClicked(sender: UIBarButtonItem?) {
        let personalController: PersonalTabsViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.personalTabsController)!
        navigationController?.pushViewController(personalController, animated: true)
    }
    
    func onRightButtonClicked(sender: UIBarButtonItem) {
        let inviteFriendView: InviteFriendsView = InviteFriendsView.loadFromNib()
        inviteFriendView.present(on: Helper.initialNavigationController().view)
    }
    
    // MARK: - Private methods
    
    fileprivate func showViewControllerInContainerView(_ viewController: UIViewController){
        
        for vc in self.childViewControllers{
            
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        self.addChildViewController(viewController)
        viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height);
        containerView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutAttribute.leading,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: containerView,
                                                        attribute: NSLayoutAttribute.leading,
                                                        multiplier: 1,
                                                        constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutAttribute.top,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: containerView,
                                                        attribute: NSLayoutAttribute.top,
                                                        multiplier: 1,
                                                        constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutAttribute.bottom,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: containerView,
                                                        attribute: NSLayoutAttribute.bottom,
                                                        multiplier: 1,
                                                        constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutAttribute.trailing,
                                                        relatedBy: NSLayoutRelation.equal,
                                                        toItem: containerView,
                                                        attribute: NSLayoutAttribute.trailing,
                                                        multiplier: 1,
                                                        constant: 0 ) );
        
        containerView.setNeedsUpdateConstraints();
    }
}
