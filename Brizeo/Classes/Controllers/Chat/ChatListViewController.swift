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

class ChatListViewController: BasicViewController {

    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    var chatController: ALMessagesViewController?
    
    // MARK: - Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(operateApplozicChat(notification:)), name: NSNotification.Name(rawValue: "GoToMessages"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Helper.mainTabBarController()?.tabBar.isHidden = false
        
        let storyboard = UIStoryboard(name: "Applozic", bundle: Bundle(for: ALChatViewController.self))
        chatController = storyboard.instantiateViewController(withIdentifier: "ALViewController") as? ALMessagesViewController
        
        showViewControllerInContainerView(chatController!)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public methods
    
    func operateApplozicChat(notification: NSNotification) {
        if let dict = notification.userInfo, let key = dict["key"] as? NSNumber {
            
            chatController!.insertChannelMessage(key)
            _ = navigationController?.popToRootViewController(animated: true)
        }
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
