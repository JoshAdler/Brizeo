//
//  BranchProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 2/12/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Branch
import SwiftyUserDefaults

extension DefaultsKeys {
    static let sharedUserId = DefaultsKey<String?>("sharedUserId")
    static let launchCount = DefaultsKey<Int>("launchCount")
}

class BranchProvider: NSObject {

    // MARK: - Types
    
    enum Feature: String {
        case invite = "invite"
    }
    
    enum Channel: String {
        case SMS = "SMS"
        case facebook = "FacebookInvite"
        case social = "social"
        case mail = "mail"
    }
    
    enum MetadataKeys: String {
        case referrerId = "referrer_id"
        case userId = "user_id"
        case momentId = "moment_id"
        case invitedByUserId = "invitedBy_user_id"
        case invitedByUserName = "invitedBy_user_name"
        case clickedOnLink = "+clicked_branch_link"
        case isFirstSession = "+is_first_session"
    }
    
    enum BuiltInKeys: String {
        case referralBucket = "successful_referral"
        case installationBucket = "installation_bucket"
        case installAfterInvitation = "InstallAfterInvitation"
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
        linkProperties.feature = Feature.invite.rawValue
        linkProperties.channel = Channel.social.rawValue
        
        branchUniversalObject.getShortUrl(with: linkProperties,  andCallback: { (url, error) -> Void in
            completionHandler(url)
        })
    }
    
    class func setupBranch(with launchOptions: [AnyHashable: Any]?) {
        
        let branch: Branch = Branch.currentInstance
        branch.initSession(launchOptions: launchOptions) { (params, error) in
            
            guard error == nil else {
                print("Branch error: \(error?.localizedDescription)")
                return
            }
            
            // check params for userId or momentId
            print("Setup Branch data: \(params?.description)")
            if let userIdToPresent = params?[MetadataKeys.userId.rawValue] as? String {
                print("user should present user id = \(userIdToPresent)")
            }
            
            if let momentIdToPresent = params?[MetadataKeys.momentId.rawValue] as? String {
                print("user should present moment id = \(momentIdToPresent)")
            }
        }
    }
    
    class func loadReward(handler: @escaping (Int?, Error?) -> Void) {
        Branch.currentInstance.loadRewards { (changed, error) -> Void in
            let bucket = BuiltInKeys.installationBucket.rawValue
            let credits = Branch.currentInstance.getCreditsForBucket(bucket)
            
            guard error != nil else {
                handler(nil, error)
                return
            }
            
            handler(credits, nil)
        }
    }
    
    class func checkUserReward() {
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: no current user for 'checkUserReward'")
            return
        }
        
        loadReward { (invitedCount, error) in
            guard invitedCount != nil else {
                print("Error: Branch invited person count is nil")
                return
            }
            
            guard invitedCount! > 0 && (invitedCount! % Configurations.RewardInfo.minInvitedUsers == 0) else {
                print("Info: user has invited only \(invitedCount) persons")
                return
            }
            
            //TODO: use method for sending emails
            //            UserProvider.sendDownloadEvent(currentUser, timesDownloaded: credits, completion: { (result) in
            //
            //                switch result {
            //                case .success(_):
            //                    break
            //                case .failure(let error):
            //                    //Error sending download event call
            //                    CLSNSLogv("ERROR: error occurred sending download event to api: %@", getVaList([error]))
            //                    break
            //                }
            //            })
        }
    }
    
    class func operateFirstEntrance(with user: User) {
        // identify current user
        Branch.currentInstance.setIdentity("\(user.objectId)-\(user.displayName)")
        
        // check referring params
        let installParams = Branch.currentInstance.getFirstReferringParams()
        
        if let clickedOnLink = installParams?[MetadataKeys.clickedOnLink.rawValue] as? Bool,
            let isFirstSession = installParams?[MetadataKeys.isFirstSession.rawValue] as? Bool {
            
            if clickedOnLink && isFirstSession {
                Branch.currentInstance.userCompletedAction(BuiltInKeys.installAfterInvitation.rawValue, withState: [String: String]())
                
                // operate who has invited the current user
                if let invitedByUserId = installParams?[MetadataKeys.invitedByUserId.rawValue] as? String, let invitedByUserName = installParams?[MetadataKeys.invitedByUserName.rawValue] as? String {
                    print("User was invited by \(invitedByUserId) - \(invitedByUserName)")
                    //TODO: save this data in the user
                }
            }
        }
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
