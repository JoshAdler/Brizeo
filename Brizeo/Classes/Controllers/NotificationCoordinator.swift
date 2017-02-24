//
//  NotificationCoordinator.swift
//  Brizeo
//
//  Created by Monkey on 9/15/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

class NotificationCoordinator: ToolbarCoordinator {
    
    init(user: User) {
        
        super.init()
        let profileVC = OtherProfileViewController(user: user)
        baseController = DefaultNavigationController(rootViewController: profileVC)
    }
    
    override func performTransition(_ transition: Transition) {
        
        let navigationController = baseController as! UINavigationController
        
        switch transition {
        case .showProfile(user: _):
            let profileVC = navigationController.topViewController as! OtherProfileViewController
            profileVC.isNotification = true
            profileVC.navigationCoordinator = self
            
            break
            
        case .userSetting:
            
            navigationController.dismiss(animated: true, completion: nil)
            
        default:
            super.performTransition(transition)
            break
        }
    }
}
