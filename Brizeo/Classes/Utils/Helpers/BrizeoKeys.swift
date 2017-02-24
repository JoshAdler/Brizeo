//
//  ParseKey.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/18/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

struct GooglePlacesKey {
    static let GooglePlacesKey = "AIzaSyAEiofIW_qR2owrLntAtoy-kH0Cq8szDrQ"
}

struct ParseKey {
    
    #if PRODUCTION
    static let ApplicationId = "ie9mLbQvoPckc7wk0qthdc53ZmKbKSQDogpAQPL2"
    static let ClientKey = "h4tJnWdjvUjdCbnIx1KYrq0D4RxPUMKgA7UHKkuZ"
    #else
    static let ApplicationId = "vGPyF6Rj211HvhaUIzVtsyXNiWOTOOVDnUWJarkV"
    static let ClientKey = "0WRp5Kq9fmPCeIuBC9a8EhWAeScNzyRt0z5hp809"
    #endif
}

struct LayerKey {
    
    #if PRODUCTION
    static let LQSLayerAppID = "layer:///apps/production/9663113a-f22c-11e5-8d42-f131e00c2810"
    static let LayerID = "layer:///providers/9661c2ee-f22c-11e5-8d42-f131e00c2810"
    #else
    static let LQSLayerAppID = "layer:///apps/staging/9663111c-f22c-11e5-8d42-f131e00c2810"
    static let LayerID = "layer:///providers/9661c2ee-f22c-11e5-8d42-f131e00c2810"
    #endif
    static let ATLMediaViewControllerSymLinkedMediaTempPath = "com.layer.atlas/media/"
}

struct AppURL {
    
    static let ShareImageVacationUrlString = "https://files.parsetfss.com/0693b1ef-dbce-4dc5-b0d9-b2e4d12cf0ab/tfss-dfc6f2f8-255a-4fbd-96cd-ce24cffc90be-upload.jpg"
    static let RewardsURL = "http://brizeo.com/rewards/"
    static let BrizeoCheckURL = "http://brizeo-fb.herokuapp.com/check"
}

struct BranchKeys {
    
    // Feature
    static let FeatureInvite = "invite"
    
    // Channel
    static let ChannelFacebook = "FacebookInvite"
    static let ChannelSocial = "social"
    static let ChannelMail = "mail"
    
    // Ids
    static let IdentifierReferrer = "referrer_id"
    
    // Bucket
    static let ReferralBucket = "successful_referral"
    static let InstallationBucket = "installation_bucket"
    
    // Validation
    static let ClickedOnLink = "+clicked_branch_link"
    static let IsFirstSession = "+is_first_session"
    static let ReferredUserId = "referred_id"
    
    // Action
    static let InstallAfterInvitation = "InstallAfterInvitation"
}

enum Result<T> {
    case success(T)
    case failure(String)
}
