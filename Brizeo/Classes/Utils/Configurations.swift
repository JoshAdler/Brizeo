//
//  Configurations.swift
//  Brizeo
//
//  Created by Roman Bayik on 1/26/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class Configurations: NSObject {

    // MARK: - MixPanel
    struct MixPanel {
        static let token = "1a26483d830e36c23ff927ef6d1394b4"
    }
    
    // MARK: - Settings
    struct Settings {
        static let minAgeValue: CGFloat = 18
        static let maxAgeValue: CGFloat = 85
        static let minDistanceValue: Float = 1
        static let maxDistanceValue: Float = 100
    }
    
    // MARK: - Dimentions
    struct Dimentions {
        static let milesPerMeter = 0.000621371
    }
    
    // MARK: - Instagram
    struct Instagram {
        static let clientId = "fff167abb2a54946804c2c57cff5d8b9"//"a692d33f462449908be6b6b08cefab10"
        static let clientSecret = "3082d7a585ae4a3b88492ea1c72bb47e"//"bc3a3780b3e1418b9a322df4fdd7ef87"
        static let redirectURL = "iga692d33f462449908be6b6b08cefab10://authorize"
    }
    
    // MARK: - General
    struct General {
        static let apiURL = "http://ec2-54-244-190-99.us-west-2.compute.amazonaws.com:3000"
        static let termsOfUseURL = "http://brizeo.com/terms/"
        static let photosCountToLoadAtStart = 4
    }
    
    // MARK: - Localytics
    struct Localytics {
        static let appKey = "asd"
    }
    
    // MARK: - Applozic
    struct Applozic {
        static let appKey = "324a31b8f131bb0d6f69f9164f3a7cfd6"
    }
    
    // MARK: - URLs that are used in the app
    struct AppURLs {
        static let ShareImageVacationURL = "https://files.parsetfss.com/0693b1ef-dbce-4dc5-b0d9-b2e4d12cf0ab/tfss-dfc6f2f8-255a-4fbd-96cd-ce24cffc90be-upload.jpg"
        static let RewardsURL = "http://brizeo.com/rewards/"
        static let BrizeoCheckURL = "http://brizeo-fb.herokuapp.com/check"
    }
    
    // MARK: - Google Places
    struct GooglePlaces {
        static let key = "AIzaSyAEiofIW_qR2owrLntAtoy-kH0Cq8szDrQ"
    }
    
    // MARK: - Reward
    struct RewardInfo {
        static let minInvitedUsers = 25
    }
    
    // MARK: - First entry
    
//    class func isFirstEntry() -> Bool {
//        return !UserDefaults.standard.bool(forKey: "HasLaunchedOnce")
//    }
//    
//    class func setUserDidEntry() {
//        UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
//        UserDefaults.standard.synchronize()
//    }
}
