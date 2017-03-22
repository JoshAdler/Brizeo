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
        case uploadImages = "uploadImages"
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
        case otherProfileImages = "otherProfileImages"
        case deviceToken = "deviceToken"
        case thumbnailImages = "thumbnailImages"
    }
    
    // MARK: - Properties
    
    // ids
    var objectId: String = "0"
    var facebookId: String!
    
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
    var profileImage: FileObjectInfo?
    var uploadFiles: [FileObject]?
    
    var thumbnailImages: [String]?
    var profileUploadImage: UIImage?
    
    // match status
    var status: MatchingStatus = .noActionsBetweenUsers
    
    // helper variables
    
    var shortName: String? {
        let displayNameArray = displayName.components(separatedBy: " ")
        
        return displayNameArray.first
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
        
        return profileImage?.url != nil
    }
    
    var profileUrl: URL? {
        guard let url = profileImage?.url else {
            return nil
        }
        return URL(string: url)
    }
    
    var allMedia: [FileObject] {
        var media = [FileObject]()
        
        if hasProfileImage {
            media.append(FileObject(info: profileImage!))
        }
        
        if uploadFiles != nil {
            media.append(contentsOf: uploadFiles!)
        }
        
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
    
    required init?(map: Map) { }
    
    init(objectId: String, facebookId: String, displayName: String?, email: String, gender: Gender, profileImageURL: String?, workInfo: String?, studyInfo: String?, uploadedURLs: [String], lastActiveDate: Date?) {
        self.objectId = objectId
        self.facebookId = facebookId
        self.gender = gender
        self.workInfo = workInfo
        self.studyInfo = studyInfo
        self.email = email
        self.lastActiveTime = lastActiveDate
        self.displayName = displayName ?? "Mr./Mrs"
        
        if let profileImageURL = profileImageURL {
            profileImage = FileObjectInfo(urlStr: profileImageURL)
        }
        
        var files = [FileObject]()
        for url in uploadedURLs {
            files.append(FileObject(info: FileObjectInfo(urlStr: url)))
        }
        uploadFiles = files
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
        profileImage <- (map[JSONKeys.profileImage.rawValue], FileObjectInfoTransform())
        uploadFiles <- (map[JSONKeys.otherProfileImages.rawValue], FileObjectTransform())
        thumbnailImages <- map[JSONKeys.thumbnailImages.rawValue]
        
        status <- (map[JSONKeys.status.rawValue], EnumTransform<MatchingStatus>())
        deviceToken <- map[JSONKeys.deviceToken.rawValue]
        
        // operate already created upload files
        if let thumbnailImages = thumbnailImages {
            
            guard let uploadFiles = uploadFiles else {
                return
            }
            
            var files = [FileObject]()
            
            for i in 0 ..< uploadFiles.count {
                
                let url = thumbnailImages[i]
                
                if url.numberOfCharactersWithoutSpaces() == 0 {
                     files.append(uploadFiles[i])
                } else {
                    
                    let newFile = FileObject(
                        thumbnailImage: FileObjectInfo(urlStr: thumbnailImages[i]),
                        videoInfo: FileObjectInfo(urlStr: uploadFiles[i].mainUrl!)
                    )
                    files.append(newFile)
                }
            }
            
            self.uploadFiles = files
            self.thumbnailImages = nil
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
