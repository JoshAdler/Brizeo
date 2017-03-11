//
//  ThemeManager.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/28/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import ChameleonFramework
import SVProgressHUD

class ThemeManager: NSObject {

    // MARK: - Types
    
    struct Constants {
        static let navigationBarColor = UIColor.white
        static let navigationBarButtonItemColor = HexColor("1f4ba5")!
        static let navigationBarButtonItemFontSize: CGFloat = 17.0
        static let navigationBarButtonItemFontName = "SourceSansPro-Semibold"
    }
    
    // MARK: - Class methods
    
    class func applyGlobalTheme() {
        
        // navigation bar
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName : Constants.navigationBarButtonItemColor,
            NSFontAttributeName: UIFont(name: Constants.navigationBarButtonItemFontName, size: Constants.navigationBarButtonItemFontSize)!]
        UINavigationBar.appearance().barTintColor = Constants.navigationBarColor
        
        // navigation bar item
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSForegroundColorAttributeName : Constants.navigationBarButtonItemColor,
            NSFontAttributeName: UIFont(name: Constants.navigationBarButtonItemFontName, size: Constants.navigationBarButtonItemFontSize)!], for: .normal)
        
        // tabbar
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().barTintColor = .clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        
        // loading HUD
        SVProgressHUD.setDefaultMaskType(.gradient)
    }
    
    class func placeLogo(on navigationItem: UINavigationItem) {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_nav_logo"))
        imageView.contentMode = .scaleAspectFit
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        navigationItem.titleView = titleView
    }
}
