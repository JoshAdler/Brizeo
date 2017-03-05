//
//  User.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/18/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Crashlytics
import Branch
import CoreLocation

struct UserParameterKey {
    static let UserIdKey = "userId"
    static let ReportedUserIdKey = "reportedUserId"
    static let TargetUserIdKey = "targetId"
    static let totalKey = "total"
}

class User: NSObject {
    
    // MARK: - Types
    
    enum JSONKeys: String {
        case age = "age"
        case facebookId = "facebookId"
        case authData = "authData"
        case id = "id"
        case facebook = "facebook"
        case displayName = "displayName"
        case email = "email"
        case gender = "gender"
        case lastActiveTime = "lastActiveTime"
        case iso = "iso"
        case countries = "countries"
        case location = "location"
        case latitude = "latitude"
        case longitude = "longitude"
        case objectId = "objectId"
        case personalText = "personalText"
        case profileImage = "profileImage"
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
    }
    
    // MARK: - Properties
    
    // ids
    var objectId: String
    var facebookId: String!
    
    // basic information
    var username: String?
    var displayName: String? = ""
    var gender: Gender
    var age: Int = 18
    var email: String
    var personalText: String = ""
    var countries: [Country] = []
    var isSuperUser: Bool = false
    var workInfo: String?
    var studyInfo: String?
    
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
    
    // helper variables
    
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
    
    // MARK: - Init methods
    
    init(objectId: String, facebookId: String, displayName: String?, email: String, gender: Gender, profileImageURL: String?, workInfo: String?, studyInfo: String?, uploadedURLs: [URL], lastActiveDate: Date?) {
        self.objectId = objectId
        self.facebookId = facebookId
        self.displayName = displayName
        self.gender = gender
        self.workInfo = workInfo
        self.studyInfo = studyInfo
        self.email = email
        self.lastActiveTime = lastActiveDate
        
        // files
        
        
    }
    
    init(with JSON: [String: Any]) {
        
        // ids
        objectId = JSON[JSONKeys.objectId.rawValue] as! String
        facebookId = JSON[JSONKeys.facebookId.rawValue] as? String
        
        // basic information
        username = JSON[JSONKeys.username.rawValue] as? String
        displayName = JSON[JSONKeys.displayName.rawValue] as? String
        gender = Gender(rawValue: JSON[JSONKeys.gender.rawValue] as! String)!
        age = JSON[JSONKeys.age.rawValue] as! Int
        email = JSON[JSONKeys.email.rawValue] as! String
        personalText = JSON[JSONKeys.personalText.rawValue] as! String
        isSuperUser = (JSON[JSONKeys.isSuperUser.rawValue] as? Bool) ?? false
        workInfo = JSON[JSONKeys.workInfo.rawValue] as? String
        studyInfo = JSON[JSONKeys.studyInfo.rawValue] as? String
        
        // countries
        if let countriesDict = JSON[JSONKeys.countries.rawValue] as? [String: String] {
            for (key, value) in countriesDict {
                let country = Country.initWith(value)
                country.sortingIndex = Int(key) ?? 0
                countries.append(country)
            }
        }
        
        // passions
        primaryPassionId = JSON[JSONKeys.primaryPassionId.rawValue] as? String
        secondaryPassionId = JSON[JSONKeys.secondaryPassionId.rawValue] as? String
        thirdPassionId = JSON[JSONKeys.thirdPassionId.rawValue] as? String
        
        // addiotional info
        numberOfMatches = JSON[JSONKeys.numberOfMatches.rawValue] as? Int ?? 0
        
        if let lastActiveTimeDict = JSON[JSONKeys.lastActiveTime.rawValue] as? [String: Any], let lastActiveTimeStr = lastActiveTimeDict[JSONKeys.iso.rawValue] as? String {
            lastActiveTime = Helper.convertStringToDate(string: lastActiveTimeStr)
        }

        // invited info
        invitedByUserId = JSON[JSONKeys.invitedByUserId.rawValue] as? String
        invitedByUserName = JSON[JSONKeys.invitedByUserName.rawValue] as? String

        // location 
        locationLongitude = JSON[JSONKeys.longitude.rawValue] as? Double
        locationLatitude = JSON[JSONKeys.latitude.rawValue] as? Double
        
        // files
        if let profileDict = JSON[JSONKeys.profileImage.rawValue] as? [String: String] {
            profileImage = FileObjectInfo(with: profileDict)
        }
        
        if let uploadedFilesDict = JSON[JSONKeys.uploadImages.rawValue] as? [String: [String: Any]] {
            for (key, value) in uploadedFilesDict {
                let file = FileObject(with: value)
                file.sortingIndex = Int(key) ?? 0
                
                uploadFiles?.append(file)
            }
        }
    }
    
    class func test() -> User {
        return UserProvider.shared.currentUser!
    }
    
    // MARK:
    
//    class func saveParseUser(_ completion: @escaping (Result<Void>) -> Void) {
//        User.current()?.saveInBackground { (success, error) in
//            if(success) {
//                
//                //                let priority = DispatchQueue.GlobalQueuePriority.default
//                
//                DispatchQueue.global().async {
//                    // do some task
//                    do {
//                        try PFUser.current()?.fetch()
//                        DispatchQueue.main.async {
//                            completion(.success())
//                        }
//                        
//                    } catch(let error as NSError) {
//                        
//                        DispatchQueue.main.async {
//                            CLSNSLogv("ERROR: Unable to refresh current user: %@", getVaList([error]))
//                            completion(.failure(error.localizedDescription))// update some UI
//                        }
//                    }
//                }
//                
//                DispatchQueue.global()
//                
//            } else {
//                completion(.failure(error!.localizedDescription))
//            }
//        }
//    }
}
