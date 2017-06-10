//
//  User.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/18/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Crashlytics
import CoreLocation
import ObjectMapper

struct UserParameterKey {
    static let UserIdKey = "userId"
    static let ReportedUserIdKey = "reportedUserId"
    static let TargetUserIdKey = "targetId"
    static let totalKey = "total"
}

enum MatchingStatus: Int {
    case noActionsBetweenUsers = 1
    case isRejectedByCurrentUser
    case isApprovedByCurrentUser
    case didRejectCurrentUser
    case didRejectEachOther
    case didRejectButCurrentApprove
    case didApproveCurrentUser
    case didApproveButCurrentReject
    case isMatched
}

class User: Mappable {
    
    // MARK: - Types
    
    enum JSONKeys: String {
        case age = "age"
        case name = "name"
        case data = "data"
        case url = "url"
        case facebookId = "facebookId"
        case id = "id"
        case facebook = "facebook"
        case displayName = "displayName"
        case email = "email"
        case gender = "gender"
        case lastActiveTime = "lastActiveTime"
        case countries = "countries"
        case latitude = "currentLocation.latitude"
        case longitude = "currentLocation.longitude"
        case objectId = "objectId"
        case personalText = "personalText"
        case profileImage = "mainProfileImage"
        case profileImageThumbnail = "mainthumbnailImage"
        case username = "username"
        case superUser = "superUser"
        case primaryPassionId = "primaryPassionId"
        case secondaryPassionId = "secondaryPassionId"
        case thirdPassionId = "thirdPassionId"
        case isSuperUser = "SuperUser"
        case workInfo = "workInfo"
        case studyInfo = "studyInfo"
        case numberOfMatches = "numberOfMatches"
        case invitedByUserId = "invitedByUserId"
        case invitedByUserName = "invitedByUserName"
        case status = "status"
        case deviceToken = "deviceToken"
        case thumbnailImages = "thumbnailImages"
        case otherProfileImages = "otherProfileImages"
        case picture = "picture"
        case nationality = "nationality"
    }
    
    // MARK: - Properties
    
    // ids
    var objectId: String = "0"
    var facebookId: String?
    
    // basic information
    var username: String?
    var displayName: String = "Mr./Mrs"
    var gender: Gender = .Man
    var age: Int = 18
    var email: String!
    var personalText: String = ""
    var countries: [Country] = []
    var isSuperUser: Bool = false
    var workInfo: String?
    var studyInfo: String?
    var nationality: String?
    
    // motification info
    var deviceToken: String?
    
    // passions
    var primaryPassionId: String?
    var secondaryPassionId: String?
    var thirdPassionId: String?
    
    var numberOfMatches: Int = 0
    var lastActiveTime: Date?
    
    // invited info
    var invitedByUserId: String?
    var invitedByUserName: String?
    
    // location
    var locationLongitude: Double?
    var locationLatitude: Double?
    
    // files
    var thumbnailImageURLs: [String]?
    var otherProfileImagesURLs: [String]?
    
    var profileImageURL: String?
    var profileImageThumbnailURL: String?
    var profileImage: FileObject?
    var uploadFiles = [FileObject]()
    
    // match status
    var status: MatchingStatus = .noActionsBetweenUsers
    
    // helper variables
    
    var shortName: String {
        let displayNameArray = displayName.components(separatedBy: " ")
        
        return displayNameArray.first ?? "Someone"
    }
    
    var isCurrent: Bool {
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't compare users because the current user is nil")
            return false
        }
        
        return objectId == currentUser.objectId
    }
    
    var hasInvitedByPerson: Bool {
        return invitedByUserId != nil
    }
    
    var hasLocation: Bool {
        if locationLongitude != nil && locationLatitude != nil {
            return true
        }
        return false
    }
    
    var location: CLLocation? {
        get {
            guard hasLocation else {
                return nil
            }
            
            return CLLocation(latitude: locationLatitude!, longitude: locationLongitude!)
        }
        set {
            locationLatitude = newValue?.coordinate.latitude
            locationLongitude = newValue?.coordinate.longitude
        }
    }
    
    var activity: String? {
        guard lastActiveTime != nil else {
            return nil
        }
        
        return LocalizableString.ActiveTimeAgo.localizedStringWithArguments([Helper.minutes(since: lastActiveTime!)])
    }
    
    var hasProfileImage: Bool {
        guard profileImage != nil else {
            return false
        }
        
        return profileImage?.imageUrl != nil
    }
    
    var profileUrl: URL? {
        return profileImage?.imageUrl
    }
    
    var allMedia: [FileObject] {
        var media = [FileObject]()
        
        if hasProfileImage {
            media.append(profileImage!)
        }
        
        media.append(contentsOf: uploadFiles)
        
        return media
    }
    
    var passionsIds: [String] {
        var ids = [String]()
        
        if primaryPassionId != nil {
            ids.append(primaryPassionId!)
        }
        
        if secondaryPassionId != nil {
            ids.append(secondaryPassionId!)
        }
        
        if thirdPassionId != nil {
            ids.append(thirdPassionId!)
        }
        
        return ids
    }
    
    var topPassionId: String? {
        
        if primaryPassionId != nil {
            return primaryPassionId!
        }
        
        if secondaryPassionId != nil {
            return secondaryPassionId!
        }
        
        if thirdPassionId != nil {
            return thirdPassionId!
        }
        
        return nil
    }
    
    var shouldBeAction: Bool {
        switch status {
        case .noActionsBetweenUsers, .didRejectCurrentUser, .didApproveCurrentUser:
            return true
        default:
            return false
        }
    }
    
    var isDeclinedByCurrentUser: Bool {
        return status == .didApproveButCurrentReject || status == .didRejectEachOther || status == .isRejectedByCurrentUser
    }
    
    // MARK: - Init methods
    
    init(fakeUserJSON: [String: Any]) {
        
        facebookId = fakeUserJSON[JSONKeys.id.rawValue] as? String
        
        if let name = fakeUserJSON[JSONKeys.name.rawValue] as? String {
            self.displayName = name
        }
        
        if let pictureDict = fakeUserJSON[JSONKeys.picture.rawValue] as? [String: Any], let data = pictureDict[JSONKeys.data.rawValue] as? [String: Any], let link = data[JSONKeys.url.rawValue] as? String {
            self.profileImage = FileObject(info: FileObjectInfo(urlStr: link)!)
        }
    }
    
    required init?(map: Map) { }
    //TODO: there is a bug here with profileImageURL
    init(objectId: String, facebookId: String, displayName: String?, email: String, gender: Gender, profileImageURL: String?, workInfo: String?, studyInfo: String?, uploadedURLs: [String], lastActiveDate: Date?) {
        self.objectId = objectId
        self.facebookId = facebookId
        self.gender = gender
        self.workInfo = workInfo
        self.studyInfo = studyInfo
        self.email = email
        self.lastActiveTime = lastActiveDate
        self.displayName = displayName ?? "Mr./Mrs"
        self.profileImageURL = profileImageURL
        
        if uploadedURLs.count > 0 {
            otherProfileImagesURLs = uploadedURLs
        }
    }
    
    func mapping(map: Map) {
        
        // ids
        objectId <- map[JSONKeys.objectId.rawValue]
        facebookId <- map[JSONKeys.facebookId.rawValue]
        
        // basic information
        username <- map[JSONKeys.username.rawValue]
        displayName <- map[JSONKeys.displayName.rawValue]
        gender <- (map[JSONKeys.gender.rawValue], EnumTransform<Gender>())
        age <- map[JSONKeys.age.rawValue]
        email <- map[JSONKeys.email.rawValue]
        personalText <- map[JSONKeys.personalText.rawValue]
        isSuperUser <- map[JSONKeys.isSuperUser.rawValue]
        workInfo <- map[JSONKeys.workInfo.rawValue]
        studyInfo <- map[JSONKeys.studyInfo.rawValue]
        nationality <- map[JSONKeys.nationality.rawValue]
        
        // countries
        countries <- (map[JSONKeys.countries.rawValue], CountriesTransform())
        
        // passions
        primaryPassionId <- map[JSONKeys.primaryPassionId.rawValue]
        secondaryPassionId <- map[JSONKeys.secondaryPassionId.rawValue]
        thirdPassionId <- map[JSONKeys.thirdPassionId.rawValue]
        
        // addiotional info
        numberOfMatches <- map[JSONKeys.numberOfMatches.rawValue]
        lastActiveTime <- (map[JSONKeys.lastActiveTime.rawValue], LastActiveDateTransform())

        // invited info
        invitedByUserId <- map[JSONKeys.invitedByUserId.rawValue]
        invitedByUserName <- map[JSONKeys.invitedByUserName.rawValue]
        
        // location
        locationLongitude <- map[JSONKeys.longitude.rawValue]
        locationLatitude <- map[JSONKeys.latitude.rawValue]
        
        // files
        profileImageURL <- map[JSONKeys.profileImage.rawValue]
        profileImageThumbnailURL <- map[JSONKeys.profileImageThumbnail.rawValue]
        thumbnailImageURLs <- map[JSONKeys.thumbnailImages.rawValue]
        otherProfileImagesURLs <- map[JSONKeys.otherProfileImages.rawValue]
        
        status <- (map[JSONKeys.status.rawValue], EnumTransform<MatchingStatus>())
        deviceToken <- map[JSONKeys.deviceToken.rawValue]
        
        // operate profile image
        profileImage = FileObject(
            thumbnailImage: FileObjectInfo(urlStr: profileImageThumbnailURL),
            imageInfo: FileObjectInfo(urlStr: profileImageURL)
        )
        
        // operate already created upload files
        uploadFiles.removeAll()
        if otherProfileImagesURLs != nil && thumbnailImageURLs != nil {
           
            for i in 0..<otherProfileImagesURLs!.count {
                
                let fileURL = otherProfileImagesURLs![i]
                var thumbnailURL: String? = nil
                
                if i < thumbnailImageURLs!.count {
                    thumbnailURL = thumbnailImageURLs![i]
                }
                
                let file = FileObject(
                    thumbnailImage: FileObjectInfo(urlStr: thumbnailURL),
                    fileInfo: FileObjectInfo(urlStr: fileURL)!
                )
                
                uploadFiles.append(file)
            }
        }
    }

    // MARK: - Public methods
    
    func removeCountry(countryToRemove: Country) {
        if let index = countries.index(of: countryToRemove) {
            countries.remove(at: index)
        }
    }
    
    func addCountry(countryToAdd: Country) {
        if !countries.contains(countryToAdd) {
            countries.append(countryToAdd)
        }
    }
    
    func assignPassionIds(dict: [String: Int]) {
        for (key, value) in dict {
            switch value {
            case 0:
                primaryPassionId = key
                break
            case 1:
                secondaryPassionId = key
                break
            case 2:
                thirdPassionId = key
                break
            default:
                break
            }
        }
    }
}
