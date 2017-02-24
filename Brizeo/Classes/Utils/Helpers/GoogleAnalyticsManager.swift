//
//  GoogleAnalyticsManager.swift
//  Brizeo
//
//  Created by Arturo on 5/16/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Google

enum GoogleAnalyticsManager {

    // MARK: Matches
    case userHitLikeDislikeAfterSeeingProfilePicture
    case userHitLikeDislikeAfterSeeingMoreInformation
    case userHitLikeDislikeAfterSeeingMoments
    // MARK: Settings
    case userSelectCity(city: String)
    case userSelectInterest(interest: String)
    case userSelectSearchFor(categories: String)
    case userSelectAgeRange(range: String)
    case userSelectCountry(country: String)
    // MARK: Pictures
    case userHaveNumberOfPictures(number: String)
    case userCreateNewMoment
    case userHitLikeMoment
    // MARK: Navigation
    case userGoToProfileFromMoment
    case userGoToProfileFromSearch
    // MARK: Share
    case userShareWithFacebook
    case userShareWithNativeShare
    
    var category: String {
        
        switch self {
        case .userHitLikeDislikeAfterSeeingProfilePicture, .userHitLikeDislikeAfterSeeingMoreInformation, .userHitLikeDislikeAfterSeeingMoments:
            return "Match"
        case .userSelectCity, .userSelectInterest, .userSelectSearchFor, .userSelectAgeRange:
            return "Settings"
        case .userHaveNumberOfPictures, .userCreateNewMoment, .userHitLikeMoment, .userSelectCountry:
            return "Profile"
        case .userGoToProfileFromMoment, .userGoToProfileFromSearch:
            return "Navigation"
        case .userShareWithFacebook, .userShareWithNativeShare:
            return "Share"
        }
    }
    
    var action: String {
        
        switch self {
        case .userHitLikeDislikeAfterSeeingProfilePicture, .userHitLikeDislikeAfterSeeingMoreInformation, .userHitLikeDislikeAfterSeeingMoments:
            return "Like/Dislike"
        case .userSelectCity, .userSelectInterest, .userSelectSearchFor, .userSelectAgeRange:
            return "Select"
        case .userHaveNumberOfPictures, .userCreateNewMoment, .userHitLikeMoment, .userSelectCountry:
            return "Increase number"
        case .userGoToProfileFromMoment, .userGoToProfileFromSearch:
            return "Navigate"
        case .userShareWithFacebook, .userShareWithNativeShare:
            return "Share"
        }
    }
    
    var label: String {
        
        switch self {
        case .userHitLikeDislikeAfterSeeingProfilePicture:
            return "First profile screen"
        case .userHitLikeDislikeAfterSeeingMoreInformation:
            return "After search for more information"
        case .userHitLikeDislikeAfterSeeingMoments:
            return "After look Moments wall"
        case .userSelectCity(let city):
            return String(format: "City - %@", city)
        case .userSelectInterest(let interest):
            return String(format: "Interest category - %@", interest)
        case .userSelectSearchFor(let categories):
            return String(format: "Search for one or more - %@", categories)
        case .userSelectAgeRange(let range):
            return String(format: "Age range - %@", range)
        case .userHaveNumberOfPictures(let number):
            return String(format: "Number of profile pictures - %@", number)
        case .userSelectCountry(let country):
            return String(format: "Country - %@", country)
        case .userCreateNewMoment:
            return "New moment published"
        case .userHitLikeMoment:
            return "New moment liked"
        case .userGoToProfileFromMoment:
            return "User profile from moment"
        case .userGoToProfileFromSearch:
            return "User profile from search"
        case .userShareWithFacebook:
            return "Friends on facebook"
        case .userShareWithNativeShare:
            return "Using native share"
        }
    }
    
    func sendEvent() {
        
        _ = GAI.sharedInstance().defaultTracker
  //      traker?.send(GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: 1).build() as [AnyHashable: Any])
    }

    static func setupGoogleAnalytics() {
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
    }
}

//SendUserPictures
extension GoogleAnalyticsManager {
    
    static func sendUserProfilePictures() {
        
        guard let user = User.current() else {
            return
        }
        
        let userDefaults = UserDefaults.standard
        if let lastSendDate = userDefaults.object(forKey: "") {
            let days = (Date() as NSDate).days(since: lastSendDate as! Date)
            if days > 1 {
                GoogleAnalyticsManager.userHaveNumberOfPictures(number: "\(user.uploadedMedia.count)").sendEvent()
            }
        } else {
            saveCurrentDate()
        }
    }
    
    fileprivate static func saveCurrentDate() {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(Date(), forKey: "lastSendDate")
    }
}
