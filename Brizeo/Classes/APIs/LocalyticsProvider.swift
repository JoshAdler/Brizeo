//
//  LocalyticsProvider.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/29/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit
import Localytics

class LocalyticsProvider: NSObject {

    // MARK: - Class methods
    
    class func trackInviteByPicture() {
        Localytics.tagInvited("SharePicture", attributes: nil)
    }
    
    class func trackInviteBySMS() {
        Localytics.tagInvited("SMS", attributes: nil)
    }
    
    class func trackInviteByEmail() {
        Localytics.tagInvited("Email", attributes: nil)
    }
    
    class func trackInviteByMessanger() {
        Localytics.tagInvited("Messanger", attributes: nil)
    }
    
    class func trackInviteByFBDialog() {
        Localytics.tagInvited("FB Invite", attributes: nil)
    }
    
    class func trackInviteByWhatsapp() {
        Localytics.tagInvited("Whatsapp", attributes: nil)
    }
    
    class func trackInviteByTwitter() {
        Localytics.tagInvited("Twitter", attributes: nil)
    }
    
    class func trackCurrentUser() {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            return
        }
        
        Localytics.setCustomerId(currentUser.objectId)
        Localytics.setValue(currentUser.age, forProfileAttribute: "Age", with: .application)
        Localytics.setValue(currentUser.gender.rawValue, forProfileAttribute: "Gender", with: .application)
        
        if let studyInfo = currentUser.studyInfo {
            Localytics.setValue(studyInfo, forProfileAttribute: "University", with: .application)
        }
    }
    
    class func trackLocation(_ coordinate: CLLocationCoordinate2D) {
        Localytics.setLocation(coordinate)
    }
    
    class func trackUnMatchPerson() {
        Localytics.incrementValue(by: 1, forProfileAttribute: "Un-matchedCount", with: .application)
    }
    
    class func trackUserDidApproved() {
        Localytics.incrementValue(by: 1, forProfileAttribute: "GreenMarkClicks", with: .application)
    }
    
    class func trackItsAMatch() {
        Localytics.incrementValue(by: 1, forProfileAttribute: "ItsAMatchCount", with: .application)
    }
    
    class func trackUserDidDeclined() {
        Localytics.incrementValue(by: 1, forProfileAttribute: "RedCrossClicks", with: .application)
    }
    
    class func trackMomentLike(momentId: String) {
        Localytics.incrementValue(by: 1, forProfileAttribute: "LikedMomentCount", with: .application)
        Localytics.tagEvent("User liked moment", attributes: ["MomentId" : momentId])
    }
    
    // MARK: - Events
    
    class func userViewNotifications() {
        Localytics.tagEvent("Notification screen")
    }
    
    class func userGoProfileFromNotifications() {
        Localytics.tagEvent("User went to Profile from Notifications")
    }
    
    class func userViewMomentsWall() {
        Localytics.tagEvent("Moments screen")
    }
    
    class func userGoProfileFromMoments() {
        Localytics.tagEvent("User went to Profile from Moments")
    }
    
    class func userGoProfileFromLikers() {
        Localytics.tagEvent("User went to Profile from Likers")
    }
    
    class func userGoProfileFromEventAttendings() {
        Localytics.tagEvent("User went to Profile from Event Attendings")
    }
    
    class func userViewLikers() {
        Localytics.tagEvent("Likers screen")
    }
}
