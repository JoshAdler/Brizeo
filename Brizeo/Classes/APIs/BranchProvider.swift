//
//  BranchProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Branch

class BranchProvider: NSObject {

    // MARK: - Types
    
    enum Feature: String {
        case invite = "invite"
    }
    
    enum Channel: String {
        case SMS = "SMS"
    }
    
    enum MetadataKeys: String {
        case userId = "user_id"
        case momentId = "moment_id"
    }
    
    // MARK: - Class methods
    
    class func generateInviteURL(forMomentId momentId: String, imageURL: String? = nil, andCallback completionHandler: @escaping (String?) -> Void) {
        generateInviteURL(forParams: [.momentId: momentId], imageURL: imageURL, andCallback: completionHandler)
    }
    
    class func generateInviteURL(forUserId userId: String, imageURL: String? = nil, andCallback completionHandler: @escaping (String?) -> Void) {
        generateInviteURL(forParams: [.userId: userId], imageURL: imageURL, andCallback: completionHandler)
    }
    
    class func generateShareURL(callback completionHandler: @escaping (String?) -> Void) {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.InviteFriends.localizedString
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = BranchKeys.FeatureInvite
        linkProperties.channel = BranchKeys.ChannelSocial
        
        branchUniversalObject.getShortUrl(with: linkProperties,  andCallback: { (url, error) -> Void in
            completionHandler(url)
        })
    }
    
    // MARK: - Private methods
    
    class private func generateInviteURL(forParams params: [MetadataKeys: String], imageURL: String?, andCallback completionHandler: @escaping (String?) -> Void) {
        let branchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.BrizeoInvite.localizedString
        branchUniversalObject.imageUrl = imageURL ?? "http://www.healthline.com/hlcmsresource/images/topic_centers/Food-Nutrition/642x361_IMAGE_1_The_7_Best_Things_About_Kiwis.jpg"
        
        for (key, value) in params {
            branchUniversalObject.addMetadataKey(key.rawValue, value: value)
        }
        
        let linkProperties = BranchLinkProperties()
        linkProperties.feature = Feature.invite.rawValue
        linkProperties.channel = Channel.SMS.rawValue
        
        branchUniversalObject.getShortUrl(with: linkProperties, andCallback: { (url, error) -> Void in
            if let error = error {
                print("BranchManager: \(error.localizedDescription)")
            }
            
            if url != nil {
                let modifiedURL = "\(LocalizableString.BrizeoInvite.localizedString) \n\n \(url!)"
                completionHandler(modifiedURL)
            } else {
                completionHandler(nil)
            }
        })
    }
}
