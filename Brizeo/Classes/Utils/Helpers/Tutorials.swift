//
//  Tutorials.swift
//  Brizeo
//
//  Created by Arturo on 4/26/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation

enum Tutorials: String {
    
    case Match = "MatchViewControllerKey"
    
    func alreadyPresentTutorial() -> Bool {
        
        let showed = alreadyShowTutorialForKey(self.rawValue)
        if !showed {
            didShowTutorialForKey(self.rawValue)
        }
        return showed
    }
    
    fileprivate func alreadyShowTutorialForKey(_ key: String) -> Bool {
        
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key)
    }
    
    fileprivate func didShowTutorialForKey(_ key: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: key)
    }
}
