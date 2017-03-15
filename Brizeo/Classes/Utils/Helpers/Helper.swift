//
//  DateFormat.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/22/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import CarbonKit
import ChameleonFramework
import SwiftDate
import AVFoundation
import AssetsLibrary

struct Resources {
    static let pushNotificationSound = "new_message.wav"
}

struct DateFormat {
    static let allComponentsFormat = "yyyy-MM-dd hh:mm:ss 'Z'"
}

struct ThemeConstants {
    static let carbonMenuFont = UIFont(name: "SourceSansPro-Semibold", size: 17.0)!
    static let carbonMenuNormalColor = HexColor("b2b2b2")!
    static let carbonMenuSelectedColor = UIColor.black
    static let carbonMenuHeight: CGFloat = 42.0
    static let carbonMenuTintColor = UIColor.white
    static let carbonMenuIndicatorHeight: CGFloat = 2.0
    static let carbonMenuIndicatorColor = HexColor("0356a2")
}
   
enum Result<T> {
    case success(T)
    case failure(APIError)
    case userCancelled(String)
}

class Helper: NSObject {
    
    // MARK: - Types
    
    struct Constants {
        static let logoHeight: CGFloat = 25.0
    }
    
    struct StoryboardIds {
        static let mainTabBarControllerId = "MainTabBarController"
    }
    
    // MARK: - Storyboard
    
    // storyboard
    class func storyboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class func controllerFromStoryboard<T>(controllerId: String) -> T? {
        guard let controller = storyboard().instantiateViewController(withIdentifier: controllerId) as? T else {
            assertionFailure("Can't create a controller from storyboard by id: \(controllerId)")
            return nil
        }
        return controller
    }
    //TODO: use sound from Josh for notifications
    // carbon
    class func createCarbonController(with items: [String], _ delegate: CarbonTabSwipeNavigationDelegate) -> CarbonTabSwipeNavigation {
        let controller = CarbonTabSwipeNavigation(items: items, delegate: delegate)
        
        // fonts & text color
        controller.setNormalColor(ThemeConstants.carbonMenuNormalColor, font: ThemeConstants.carbonMenuFont)
        controller.setSelectedColor(ThemeConstants.carbonMenuSelectedColor, font: ThemeConstants.carbonMenuFont)
        
        // bar
        controller.setTabBarHeight(ThemeConstants.carbonMenuHeight)
        controller.toolbar.barTintColor = ThemeConstants.carbonMenuTintColor
        controller.toolbar.alpha = 1.0
        controller.toolbar.backgroundColor = .white
        controller.toolbar.isTranslucent = false
        
        // indicator
        controller.setIndicatorHeight(2.0)
        controller.setIndicatorColor(ThemeConstants.carbonMenuIndicatorColor)
        
        for i in 0...items.count - 1 {
            controller.carbonSegmentedControl?.setWidth(UIScreen.main.bounds.width / CGFloat(items.count), forSegmentAt: i)
        }
        
        return controller
    }
    
    // general
    class func openURL(url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // tab bar
    class func selectedTabBarItem(with index: Int) {
        if let navigationController = AppDelegate.shared().window?.rootViewController as? UINavigationController, let tabBarController = navigationController.viewControllers.first as? MainTabBarController {
            tabBarController.selectedIndex = index
        }
    }
    
    class func createMainTabBarController() -> MainTabBarController {
        return controllerFromStoryboard(controllerId: StoryboardIds.mainTabBarControllerId)!
    }
    
    class func mainTabBarController() -> MainTabBarController? {
        if let navigationController = AppDelegate.shared().window?.rootViewController as? MainNavigationViewController {
            if navigationController.viewControllers.count > 1 {
                return navigationController.viewControllers[1] as? MainTabBarController
            }
        }
        
        return nil
    }
    
    class func carbonViewHeight() -> CGFloat {
        return ThemeConstants.carbonMenuHeight
    }
    
    // MARK: - Navigation
    
    class func placeLogo(on navigationItem: UINavigationItem?) {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_nav_logo"))
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: Constants.logoHeight)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white

        navigationItem?.titleView = imageView
    }
    
    class func initialNavigationController() -> MainNavigationViewController {
        let navigationController = AppDelegate.shared().window?.rootViewController as! MainNavigationViewController
        return navigationController
    }
    
    class func initialNavigationItem() -> UINavigationItem? {
        return initialNavigationController().viewControllers.first?.navigationItem
    }
    
    class func goToInitialController(_ animated: Bool) {
        initialNavigationController().popToRootViewController(animated: animated)
    }
    
    class func currentTabNavigationController() -> MainNavigationViewController? {
        if let tabBarController = Helper.mainTabBarController() {
            
            let index = tabBarController.selectedIndex
            return tabBarController.viewControllers?[index] as? MainNavigationViewController
        }
        return nil
    }
    
    // MARK: - Date methods
    
    class func convertStringToDate(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.date(from: string)
    }
    
    class func minutes(since date: Date) -> String {
        var minutes = (Date() as NSDate).minute(since: date)
        
        if minutes < 0 {
            minutes = -minutes
        }
        
        if minutes > 60 {
            return hours(since: date)
        } else {
            return LocalizableString.Minutes.localizedStringWithArguments([minutes])
        }
    }
    
    class func hours(since date: Date) -> String {
        var hours = (Date() as NSDate).hours(since: date)
        
        if hours < 0 {
            hours = -hours
        }
        if hours > 24 {
            return days(since: date)
        } else {
            return LocalizableString.Hours.localizedStringWithArguments([hours])
        }
    }
    
    class func days(since date: Date) -> String {
        
        var days = (Date() as NSDate).days(since: date)
        if days < 0 {
            days = -days
        }
        return LocalizableString.Days.localizedStringWithArguments([days])
    }
    
    // MARK: - Notifications
    
    class func sendNotification(with name: String, object: Any?, dict: [String: Any]?) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: name), object: object, userInfo: dict)
    }
    
    // MARK: - Video
    
    class func generateThumbnail(from path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}



