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
        static let clientId = "a692d33f462449908be6b6b08cefab10"
        static let clientSecret = "bc3a3780b3e1418b9a322df4fdd7ef87"
        static let redirectURL = "iga692d33f462449908be6b6b08cefab10://authorize"
    }
    
    // MARK: - General
    struct General {
        static let termsOfUseURL = "http://brizeo.com/terms/"
        static let photosCountToLoadAtStart = 4
    }
    
    // MARK: - Localytics
    struct Localytics {
        static let appKey = ""
    }
    
    // MARK: - First entry
    
    class func isFirstEntry() -> Bool {
        return !UserDefaults.standard.bool(forKey: "HasLaunchedOnce")
    }
    
    class func setUserDidEntry() {
        UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
        UserDefaults.standard.synchronize()
    }
}
