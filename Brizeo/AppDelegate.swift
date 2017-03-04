//
//  AppDelegate.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/13/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import UIKit
import Branch
import Mixpanel
import Fabric
import Crashlytics
import Parse
import Google
//TODO: remove unnecesary imports
import UserNotifications
import FBSDKLoginKit
import Localytics

import Applozic

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Types
    
    struct StoryboardIds {
        static let loginController = "LoginViewController"
    }
    
    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - AppDelegate livecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // apply main theme for the app
        ThemeManager.applyGlobalTheme()
        
        // setup 3rd parties
        setupFabric()
        setupMixpanel()
        //setupLocalytics(with: launchOptions)
        setupApplozic(with: launchOptions)
        
        // setup Facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        registerForPushNotifications()
        // TODO: replace chat initialization on login
        //LayerManager.sharedManager.loginLayer()

        // TODO: replace GoogleAnalytics
//        GoogleAnalyticsManager.setupGoogleAnalytics()
//        GoogleAnalyticsManager.sendUserProfilePictures()

        // setup managers
        LocationManager.setup()
        BranchProvider.setupBranch(with: launchOptions)
        
        // fetch initial data to cache 
        PassionsProvider.shared.retrieveAllPassions(false, nil)
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // mixpanel
        let mixPanel = Mixpanel.sharedInstance()
        mixPanel.track("App_Session")
        
        // applozic
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.disconnect()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APP_ENTER_IN_BACKGROUND"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // mixpanel
        let mixPanel = Mixpanel.sharedInstance()
        mixPanel.timeEvent("App_Session")
  
        // check how many persons were invited by current user
        BranchProvider.checkUserReward()
        
        // update current user location
        LocationManager.updateUserLocation()
        
        // applozic implementation
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.connect()
        ALPushNotificationService.applicationEntersForeground()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APP_ENTER_IN_FOREGROUND"), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()

        
        //TODO: use API method to make badge count = 0
//        guard let currentInstallation = PFInstallation.current() else {
//            assertionFailure("Error: no current installation from backend")
//            return
//        }
//        
//        if currentInstallation.badge != 0 {
//            currentInstallation.badge = 0
//            currentInstallation.saveEventually()
//        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        if Branch.currentInstance.handleDeepLink(url) {
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return Branch.currentInstance.continue(userActivity)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        ALDBHandler.sharedInstance().saveContext()
    }
    
    // MARK: - Class methods
    
    class func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
//TODO: ask Josh about whether we will use push notifications from Firebase
//MARK: - Utils
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    fileprivate func registerForPushNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if granted {
                print("User successfully granted access for notifications")
            } else {
                print("User not allowed to access for notifications")
                if error != nil {
                    print("Notification error: \(error)")
                }
            }
        }

        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
}

//MARK: - Push Notifications
extension AppDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)") // (SWIFT = 3):TOKEN PARSING
        
        var deviceTokenString: String = ""
        
        for i in 0..<deviceToken.count {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        //        let characterSet: CharacterSet = CharacterSet(charactersIn: "<>") // (SWIFT < 3):TOKEN PARSING
        //
        //        let deviceTokenString: String = (deviceToken.description as NSString)
        //            .trimmingCharacters( in: characterSet )
        //            .replacingOccurrences(of: " ", with: "") as String
        //
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")
        
        if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString) {
            
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                print (response)
            })
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error updating device token \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        PFPush.handle(userInfo)
        print("Received notification :: \(userInfo.description)")
        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
        alPushNotificationService.notificationArrived(to: application, with: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received notification With Completion :: \(userInfo.description)")
        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
        
        alPushNotificationService.notificationArrived(to: application, with: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

// MARK: - Init/Setup 3rd Patry SDKs
extension AppDelegate {
    
    fileprivate func setupApplozic(with launchOptions: [AnyHashable: Any]?) {
        let alApplocalNotificationHnadler : ALAppLocalNotifications =  ALAppLocalNotifications.appLocalNotificationHandler();
        alApplocalNotificationHnadler.dataConnectionNotificationHandler();
        
        if (launchOptions != nil) {
            let dictionary = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
            
            if (dictionary != nil) {
                print("launched from push notification")
                let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
                
                let appState: NSNumber = NSNumber(value: 0)
                let applozicProcessed = alPushNotificationService.processPushNotification(launchOptions,updateUI:appState)
                if (!applozicProcessed) {
                    
                }
            }
        }
    }
    
    fileprivate func setupFabric() {
        Fabric.with([Crashlytics.self])
    }
    
    fileprivate func setupLocalytics(with launchOptions: [AnyHashable: Any]?) {
        Localytics.autoIntegrate(Configurations.Localytics.appKey, launchOptions: launchOptions)
    }
    
    fileprivate func setupMixpanel() {
        let mixpanel = Mixpanel.sharedInstance(withToken: Configurations.MixPanel.token)
        mixpanel.timeEvent("App_Session")
    }
}
