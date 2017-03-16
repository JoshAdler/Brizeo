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
    static let userIdToPresent = DefaultsKey<String?>("userIdToPresent")
    static let momentIdToPresent = DefaultsKey<String?>("momentIdToPresent")
}
//TODO: check invited by link
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
    
    class func inviteByParams(otherParams: [MetadataKeys: String]?) -> [MetadataKeys: String] {
        var params = [
            MetadataKeys.invitedByUserId: UserProvider.shared.currentUser!.objectId,
            MetadataKeys.invitedByUserName: UserProvider.shared.currentUser!.displayName
        ]
        
        if let otherParams = otherParams {
            for (key, value) in otherParams {
                params[key] = value
            }
        }
        
        return params
    }
    
    class func userIdToPresent() -> String? {
        return Defaults[.userIdToPresent]
    }
    
    class func momentIdToPresent() -> String? {
        return Defaults[.momentIdToPresent]
    }
    //TODO: use this method
    class func clearPresentData() {
        Defaults[.userIdToPresent] = nil
        Defaults[.momentIdToPresent] = nil
    }
    
    class func generateInviteURL(forMomentId momentId: String, imageURL: String? = nil, andCallback completionHandler: @escaping (String?) -> Void) {
        
        let params = self.inviteByParams(otherParams: [.momentId: momentId])
        
        generateInviteURL(forParams: params, imageURL: imageURL, andCallback: completionHandler)
    }
    
    class func generateInviteURL(forUserId userId: String, imageURL: String? = nil, andCallback completionHandler: @escaping (String?) -> Void) {
        
        let params = self.inviteByParams(otherParams: [.userId: userId])
        
        generateInviteURL(forParams: params, imageURL: imageURL, andCallback: completionHandler)
    }
    
    class func generateShareURL(callback completionHandler: @escaping (String?) -> Void) {
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.InviteFriends.localizedString

        for (key, value) in self.inviteByParams(otherParams: nil) {
            branchUniversalObject.addMetadataKey(key.rawValue, value: value)
        }
        
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
            
            if FirstEntranceProvider.shared.isFirstEntrancePassed == false {
                return
            }
            
            // check params for userId or momentId
            print("Setup Branch data: \(params?.description)")
            if let userIdToPresent = params?[MetadataKeys.userId.rawValue] as? String {
                print("user should present user id = \(userIdToPresent)")
                Defaults[.userIdToPresent] = userIdToPresent
            }
            
            if let momentIdToPresent = params?[MetadataKeys.momentId.rawValue] as? String {
                print("user should present moment id = \(momentIdToPresent)")
                Defaults[.momentIdToPresent] = momentIdToPresent
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
        
        loadReward { (invitedCount, error) in
            guard invitedCount != nil else {
                print("Error: Branch invited person count is nil")
                return
            }
            
            guard invitedCount! > 0 && (invitedCount! % Configurations.RewardInfo.minInvitedUsers == 0) else {
                print("Info: user has invited only \(invitedCount) persons")
                return
            }
            
            InfoProvider.notifyAdminAboutDownloads(count: invitedCount!, completion: nil)
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
                    
                    user.invitedByUserId = invitedByUserId
                    user.invitedByUserName = invitedByUserName
                    
                    UserProvider.updateUser(user: user, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    class private func generateInviteURL(forParams params: [MetadataKeys: String], imageURL: String?, andCallback completionHandler: @escaping (String?) -> Void) {
        
        let branchUniversalObject = BranchUniversalObject()
        branchUniversalObject.title = LocalizableString.Brizeo.localizedString
        branchUniversalObject.contentDescription = LocalizableString.BrizeoInvite.localizedString
        branchUniversalObject.imageUrl = imageURL ?? Configurations.Invite.previewURL
        
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
            
            completionHandler(url)
        })
    }
}
