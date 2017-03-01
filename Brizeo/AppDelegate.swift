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
import LayerKit
import Fabric
import Crashlytics
import Parse
import Google
//TODO: remove unnecesary imports
import UserNotifications
import FBSDKLoginKit
import Localytics
import FontBlaster

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
        
        ThemeManager.applyGlobalTheme()
        
        // set initial tab bar item
        Helper.selectedTabBarItem(with: 2)
        
        Fabric.with([Crashlytics.self])
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupBranchIO(launchOptions)
        setupMixpanel()
        setupParse(launchOptions)
        //setupLocalytics(launchOptions)
        
        registerForPushNotifications()
        
        LayerManager.sharedManager.loginLayer()
        GoogleAnalyticsManager.setupGoogleAnalytics()
        GoogleAnalyticsManager.sendUserProfilePictures()

        LocationManager.setup()
        updateUserLocationIfPossible()
        User.checkUserRewards()
        ChatProvider.registerUserInChat()

        // chat logic
        
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
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let mixPanel = Mixpanel.sharedInstance()
        mixPanel.track("App_Session")
        
        print("APP_ENTER_IN_BACKGROUND")
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.disconnect()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APP_ENTER_IN_BACKGROUND"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let mixPanel = Mixpanel.sharedInstance()
        mixPanel.timeEvent("App_Session")
  
        updateUserLocationIfPossible()
        User.checkUserRewards()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // applozic implementation
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.connect()
        ALPushNotificationService.applicationEntersForeground()
        print("APP_ENTER_IN_FOREGROUND")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APP_ENTER_IN_FOREGROUND"), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        guard let currentInstallation = PFInstallation.current() else {
            assertionFailure("Error: no current installation from backend")
            return
        }
        
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
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
    
    // MARK: - Public methods
    
    func presentLoginScreenIfNeeds() -> Bool {
        if !UserProvider.isAlreadyLoggedIn() {
            let loginController: LoginViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.loginController)!
            Helper.initialNavigationController().pushViewController(loginController, animated: false)
            return true
        }
        
        return false
    }
    
    func logOut() {
        let loginController: LoginViewController = Helper.controllerFromStoryboard(controllerId: StoryboardIds.loginController)!
        
        guard let rootNavigationController = window?.rootViewController as? UINavigationController else {
            print("Root controller is not navigation")
            return
        }
        
        // present login screen at first and only then dismiss everything to the root
        rootNavigationController.present(loginController, animated: true) { 
            rootNavigationController.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func setupLocalytics(_ launchOptions: [AnyHashable: Any]?) {
        Localytics.autoIntegrate(Configurations.Localytics.appKey, launchOptions: launchOptions)
    }
    
    fileprivate func setupBranchIO(_ launchOptions: [AnyHashable: Any]?) {
        let branch: Branch = Branch.currentInstance
        branch.initSession(launchOptions: launchOptions) { (params, error) in
            if error == nil {
                print(params?.description)
            }
            // TODO: save here invited by person to use next
            print("Branch error: \(error?.localizedDescription)")
        }
    }
    
    fileprivate func setupMixpanel() {
        let mixpanel = Mixpanel.sharedInstance(withToken: Configurations.MixPanel.token)
        mixpanel.timeEvent("App_Session")
    }
    
    fileprivate func setupParse(_ launchOptions: [AnyHashable: Any]?) {
        
        User.registerSubclass()
        Preferences.registerSubclass()
        Interest.registerSubclass()
        Moment.registerSubclass()
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = ParseKey.ApplicationId
            $0.clientKey = ParseKey.ClientKey
            $0.server = "https://parseapi.back4app.com"
            $0.isLocalDatastoreEnabled = true // If you need to enable local data store
        }
        Parse.initialize(with: configuration)
        
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions, block: nil)
    }
    
    fileprivate func updateUserLocationIfPossible() {
        if !UserProvider.isAlreadyLoggedIn() {
            return
        }
        
        _ = LocationManager.shared.requestCurrentLocation { (locationString, location) in
            if let location = location {
                print("Current location: \(locationString) | \(location)")
                //currentUser.location = PFGeoPoint(location: location)
                User.saveParseUser({ (result) in
                })
            }
        }
    }
}

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
        
        // PREVIOUS REALIZATION
        /*
//        guard let currentInstallation = PFInstallation.current() else {
//            assertionFailure("Error: no current installation from backend")
//            return
//        }
//        
//        currentInstallation.setDeviceTokenFrom(deviceToken)
//        currentInstallation.saveInBackground(block: nil)
//        currentInstallation.saveInBackground()
//        do {
//            try LayerManager.sharedManager.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
//        } catch {
//            print("Error updating device token")
//        }*/
        
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)") // (SWIFT = 3):TOKEN PARSING
        
        var deviceTokenString: String = ""
        for i in 0..<deviceToken.count
        {
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
