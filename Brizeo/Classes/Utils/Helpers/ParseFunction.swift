//
//  ParseFunction.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation

enum ParseFunction: String {

    //MARK: - Matches
    case GetUserMatches = "matches"
    case PossibleMatches = "possibleMatches"
    case LikeUser = "like"
    case PassUser = "pass"
    
    //MARK: - Moments
    case GetEverybodyMoments = "getEverybodyMoments"
    case GetMatchesMoments = "getMatchesMoments"
    case GetUserMoments = "getUserMoments"
    case GetMomentLikes = "getMomentImageLikes"
    case GetCountUserMoments = "countUserMoments"
    case GetUserDidLikeMoment = "userLikeMoment"
    case LikeMoment = "likeMomentImage"
    case UnlikeMoment = "unlikeMomentImage"
    case DeleteMoment = "deleteMomentImage"
    
    // MARK: SuperUser
    case AddMatchSuperUser = "addSuperUserMatch"
    case SuperUserMoment = "superUserMoment"
    
    // MARK: Report
    case ReportMoment = "reportImage"
    case ReportUser = "reportUser"
    
    // MARK: RemoveMatch
    case RemoveMatch = "removeMatch"
    
    // MARK: Rewards
    case DownloadEvent = "downloadEvent"
    
    // MARK: Layer
    case LayerToken = "generateToken"
    
    var name: String {
        return self.rawValue
    }
}
