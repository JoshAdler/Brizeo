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
import FBSDKLoginKit
import Localytics
import UserNotifications
import Firebase
import Reachability
import Applozic

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Types
    
    struct StoryboardIds {
        static let loginController = "LoginViewController"
    }
    
    // MARK: - Properties
    
    var reach: Reachability?
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    static var originalAppDelegate: AppDelegate!

    // MARK: - AppDelegate livecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        AppDelegate.originalAppDelegate = self
    
        // apply main theme for the app
        ThemeManager.applyGlobalTheme()
        
        // setup 3rd parties
        setupReachability()
        setupFirebase()
        setupFabric()
        setupMixpanel()
        setupLocalytics(with: launchOptions)
        setupApplozic(with: launchOptions)

        registerForPushNotifications(application: application)
        
        // setup Facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // setup managers
        LocationManager.setup()
        BranchProvider.setupBranch(with: launchOptions)
        
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
        
        // firebase
        FIRMessaging.messaging().disconnect()
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
        
        // firebase
        connectToFcm()
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
        return originalAppDelegate
    }
}

//MARK: - Utils
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    fileprivate func registerForPushNotifications(application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                Localytics.didRequestUserNotificationAuthorization(withOptions: authOptions.rawValue, granted: granted)
        })
        
        FIRMessaging.messaging().remoteMessageDelegate = self

        application.registerForRemoteNotifications()
    }
}

//MARK: - Push Notifications
extension AppDelegate {
    //method to operate notifications when the app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("userNotificationCenter, willPresent")
    
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let dict = userInfo as? [String: Any] {
            let pushNotification = PushNotification(dict: dict)
            
            if pushNotification.hasInfo {
                NotificationProvider.operatePush(pushNotification)
            }
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(.badge)
    }
    
    // Handle notification messages after display notification is tapped by the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
        print("userNotificationCenter, didReceive")
        
        // localytics notification
        Localytics.didReceiveNotificationResponse(userInfo: response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let dict = userInfo as? [String: Any] {
            let pushNotification = PushNotification(dict: dict)
            
            if pushNotification.hasInfo {
                NotificationProvider.operatePush(pushNotification)
            }
        }
        
        completionHandler()
    }
    
    @objc func tokenRefreshNotification(_ notification: Any) {
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        
            NotificationProvider.shared.currentToken = refreshedToken
            NotificationProvider.updateCurrentUserToken()
        } else {
            if let notification = notification as? NSNotification, let newToken = notification.object as? String {
                
                if NotificationProvider.shared.currentToken != newToken {
                    NotificationProvider.shared.currentToken = newToken
                    NotificationProvider.updateCurrentUserToken()
                }
            }
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {

        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect to FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // firebase
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .sandbox)

        // save token
        NotificationProvider.shared.currentToken = FIRInstanceID.instanceID().token()
        NotificationProvider.updateCurrentUserToken()
        
        // applozic
        var deviceTokenString: String = ""
        
        for i in 0..<deviceToken.count {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        print("DEVICE_TOKEN_STRING_APPLOZIC :: \(deviceTokenString)")
        
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

        print("Received notification :: \(userInfo.description)")
        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
        alPushNotificationService.notificationArrived(to: application, with: userInfo)
        
        
        print("method - didReceiveRemoteNotification, userinfo")
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        if let dict = userInfo as? [String: Any] {
            let pushNotification = PushNotification(dict: dict)
            
            if pushNotification.hasInfo {
                NotificationProvider.operatePush(pushNotification)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
        let applozicProcessed = alPushNotificationService.processPushNotification(userInfo, updateUI: NSNumber(value: application.applicationState == UIApplicationState.active))
        
        if (applozicProcessed) {
            
            //Note: notification for app
            return
        }

        
//        // applozic
//        print("Received notification With Completion :: \(userInfo.description)")
//        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
//        
//        alPushNotificationService.notificationArrived(to: application, with: userInfo)
        
        // firebase
        if let messageId = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageId)")
        }
        
        // Print full message.
        print("\(userInfo)")
        
        if let dict = userInfo as? [String: Any] {
            let pushNotification = PushNotification(dict: dict)
            
            if pushNotification.hasInfo {
                NotificationProvider.operatePush(pushNotification)
            }
        }
        
        completionHandler(.newData)
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
    
    fileprivate func setupFirebase() {
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    }
    
    fileprivate func setupReachability() {
        
        // Allocate a reachability object
        self.reach = Reachability.forInternetConnection()
        
        // Set the blocks
        self.reach!.reachableBlock = {
            (reach: Reachability?) -> Void in
            
            if UserProvider.shared.authToken == nil {
                print("Don't load anything because we don't have a auth token")
                return
            }
            
            PassionsProvider.shared.getAllPassions(completion: nil)
            
            // save token
            NotificationProvider.updateCurrentUserToken()
            
            // save user/preferences
            if let currentUser = UserProvider.shared.currentUser {
                UserProvider.updateUser(user: currentUser, completion: nil)
            }
            
            // update preferences
            if let preferences = PreferencesProvider.shared.currentUserPreferences {
                PreferencesProvider.updatePreferences(preferences: preferences, completion: nil)
                preferences.updateApplozicNotificationMode()
            } else {
                if let currentUser = UserProvider.shared.currentUser {
                    PreferencesProvider.loadPreferences(for: currentUser.objectId, fromCache: false, completion: nil)
                }
            }
            
            // update facebook events for current user
            EventsProvider.updateUserEventsIfNeeds()
            
            // keep in mind this is called on a background thread
            // and if you are updating the UI it needs to happen
            // on the main thread, like this:
            DispatchQueue.main.async {
                print("REACHABLE!")
            }
        }
        
        self.reach!.unreachableBlock = {
            (reach: Reachability?) -> Void in
            print("UNREACHABLE!")
        }
        
        self.reach!.startNotifier()
    }
}

// MARK: - FIRMessagingDelegate
extension AppDelegate: FIRMessagingDelegate {
    
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        
        print("method - applicationReceivedRemoteMessage")
        print("\(remoteMessage.appData)")
    }
}
