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
        static let redirectURL = "https://localhost/service/generate-instagram-access-token/"//"iga692d33f462449908be6b6b08cefab10://authorize"
    }
    
    // MARK: - General
    struct General {
        static let apiURL = "http://34.208.151.167:3000"/*"http://ec2-54-244-190-99.us-west-2.compute.amazonaws.com:3000"*/
        static let termsOfUseURL = "http://brizeo.com/terms/"
        static let photosCountToLoadAtStart = 5
    }
    
    // MARK: - Localytics
    struct Localytics {
        static let appKey = "0b17f3d9a8b43eb9365c298-916e3088-9c82-11e6-ac90-0098ae15fcaa"
    }
    
    // MARK: - Applozic
    struct Applozic {
        static let appKey = "324a31b8f131bb0d6f69f9164f3a7cfd6"
        static let superUserId = "WlsuoQxwUB"
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
    
    // MARK: - Invite
    struct Invite {
        static let previewURL = "https://firebasestorage.googleapis.com/v0/b/brizeo-7571c.appspot.com/o/InviteImages%2FBroaden%20your%20Inner%20CircleThrough%20Moments.png?alt=media&token=6b6317ff-f01c-4a58-b2b8-b46bd7be3c32"//"https://firebasestorage.googleapis.com/v0/b/brizeo-7571c.appspot.com/o/InviteImages%2Finvite_brizeo.png?alt=media&token=8962285f-48d2-4965-a3f7-735ee83b90ec"
    }
    
}
