//
//  MatchsNotificationCoordinator.swift
//  Brizeo
//
//  Created by Monkey on 9/26/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit

class MatchsNotificationCoordinator: ToolbarCoordinator {
    
    init(users: [User]) {
        
        super.init()
        let matchNotificationVC = MatchNotificationViewController()
        matchNotificationVC.potentialMatches = users
        baseController = DefaultNavigationController(rootViewController: matchNotificationVC)
    }
    
    override func performTransition(_ transition: Transition) {
        
        let navigationController = baseController as! UINavigationController
        
        switch transition {
        case .showNotifications:
            let matchNotificationVC = navigationController.topViewController as! MatchNotificationViewController
            matchNotificationVC.navigationCoordinator = self
            
            break
            
        case .userSetting:
            
            navigationController.dismiss(animated: true, completion: nil)
            
        default:
            super.performTransition(transition)
            break
        }
    }
}
