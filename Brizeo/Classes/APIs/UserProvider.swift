//
//  UserProvider.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/19/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Crashlytics
import Alamofire
import CoreLocation
import FBSDKLoginKit
import Moya
import Moya_ObjectMapper
import FBSDKShareKit
import Applozic

enum UpdateFileType: String {
    case main
    case other
}

class UserProvider: NSObject {
    
    // MARK: - Types
    
    enum LoginError : Swift.Error {
        case noBirthday
    }
    
    struct FacebookConstants {
        static let permissions = ["public_profile", "email", "user_photos", "user_birthday", "user_friends", "user_education_history", "user_work_history", "user_events"]
        static let parameters = ["fields" : "id, email, first_name, last_name, name, birthday, gender, work, education, picture.width(1000).height(1000), albums{photos.height(1000){images},name}"]
        static let eventParameters = ["fields" : "events.limit(30).since(){name,description,cover,is_canceled,attending_count,rsvp_status,start_time,place,id,attending.limit(100){id},interested.limit(100){id},interested_count}"]
        
        static let newEventsParameters = ["fields" : "events.limit(50).since(){name,description,cover,is_canceled,attending_count,rsvp_status,start_time,place,id,interested_count}"]
        static let newEventParameters = ["fields" : "attending.limit(1000){installed,id},interested.limit(1000){id,installed}"]

        static let shortParameters = ["fields" : "work, education"]
        static let workParameters = ["fields" : "work"]
        static let educationParameters = ["fields" : "education"]
    }
    
    struct JSONKeys {
        static let jwt = "jwt"
    }

    typealias UserCompletion = (Result<User>) -> Void
    typealias UsersCompletion = (Result<[User]>) -> Void
    typealias MutualFriendsCompletion = (Result<(Int, [User])>) -> Void
    typealias EmptyCompletion = (Result<Void>) -> Void
    
    // MARK: - Properties
    
    static let shared = UserProvider()
    
    var currentUser: User?
    var needToSaveChanges: Bool = false
    var authToken: String?
    
    // MARK: - Init
    
    private override init() {}
    
    // MARK: - Methods
    
    class func isUserLoggedInFacebook() -> Bool {
        if FBSDKAccessToken.current() != nil {
            return true
        }
        return false
    }
    
    class func logout() {
        print("LOGOUT USER")
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        ChatProvider.logout()
        BranchProvider.logout()
        
        // erase token for pushes
        if shared.currentUser != nil {
            
            shared.currentUser?.deviceToken = ""
            UserProvider.updateUser(user: shared.currentUser!, completion: nil)
            shared.authToken = nil
        }
        
        shared.currentUser = nil
    }
    
    class func loadUser(completion: ((Result<User>) -> Void)?) {

        guard let facebookId = FBSDKAccessToken.current().userID else {
            print("Error: Can't load user without normal token")
            completion?(.failure(APIError.unknown(message: "Your current session is expired. Please login.")))
            return
        }
        
        // David 10203847100897725
        // Josh 10153844300844791
        // Superuser 112753052483419
        
        // load user by facebook id
        let provider = APIService.APIProvider()
        provider.request(.getCurrentUser(facebookId: facebookId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    // parse auth token
                    shared.authToken = try response.mapString(atKeyPath: JSONKeys.jwt)
                    
                    let user = try response.mapObject(User.self)
                    shared.currentUser = user
                    
                    ChatProvider.registerUserInChat(completionHandler: { (isSuccess) in
                        if isSuccess {
                            
                            completion?(.success(user))
                            
                            // load preferences
                            PreferencesProvider.loadPreferences(for: user.objectId, fromCache: false, completion: nil)                            
                        } else {
                            print("Can't register user in Chat")
                            completion?(.failure(APIError.unknown(message: "Error: Can't register Applozic user")))
                        }
                    })
//                    ChatProvider.registerUserInChat(completionHandler: nil)
                }
                catch (let error) {
                    completion?(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func updateUser(user: User, completion: ((Result<User>) -> Void)?) {
        
        APIService.performRequest(request: .updateUser(user: user)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                shared.currentUser = user
                shared.needToSaveChanges = true
                completion?(.success(user))
                
                break
            case .failure(let error):
                completion?(.failure(APIError(error: error)))
                
                if completion == nil {
                    shared.needToSaveChanges = true
                }
                break
            }
        }
    }
    
    class func logInUser(with location: CLLocation?, from controller: UIViewController, completion: @escaping ((Result<User>) -> Void)) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: FacebookConstants.permissions, from: controller) { (result, error) in
        
            controller.showBlackLoader()
            
            guard error == nil else {
                CLSNSLogv("ERROR: Error logging into Facebook: %@", getVaList([error! as CVarArg]))
                completion(.failure(APIError(error: error!)))
                return
            }
            
            guard result != nil else {
                completion(.failure(APIError(code: 0, message: "No result")))
                return
            }
            
            guard result!.isCancelled == false else {
                completion(.userCancelled("You has cancelled sign in process."))
                return
            }
            
            // try to load user by facebook id
            loadUser(completion: { (result) in
                switch result {
                case .success(_): // reuse already created user
                    completion(result)
                    break
                case .failure(let error): // no user with such facebook id
                    if error != APIError.notFound {
                        completion(.failure(APIError(error: error)))
                        return
                    }
                    
                    fetchUserInfoFromFacebook(completion: { (result) in
                        switch(result) {
                        case .failure(let error):
                            CLSNSLogv("ERROR: Unable to retrieve user details from Facebook: %@", getVaList([error as CVarArg]))
                            completion(.failure(error))
                            break
                        case .success(let user):
                            
                            // create new user with a FB data
                            createUser(user: user, completion: { (result) in
                                switch(result) {
                                case .failure(let error):
                                    CLSNSLogv("ERROR: Unable to create user from Facebook: %@", getVaList([error as CVarArg]))
                                    completion(.failure(error))
                                    break
                                case .success(let user):
                                    shared.currentUser = user
                                    
                                    // load preferences
                                    PreferencesProvider.loadPreferences(for: user.objectId, fromCache: false, completion: nil)
                                    
                                    BranchProvider.operateFirstEntrance(with: user)
                                    
                                    ChatProvider.registerUserInChat(completionHandler: { (isSuccess) in
                                        if isSuccess {
                                            
                                            print("Successfully created Applozic user")
                                            ChatProvider.createChatWithSuperuser()
                                            ChatProvider.createMatchingChat(with: Configurations.Applozic.superUserId)
                                        } else {
                                            print("Failed to create Applozic user")
                                        }
                                    })
                                    
                                    completion(.success(user))
                                    break
                                default:
                                    break
                                }
                            })
                            break
                        default:
                            break
                        }
                    })
                    break
                default:
                    break
                }
            })
        }
    }
    
    class func updateUserFile(file: FileObject?, type: UpdateFileType, oldURL: String?, completion: @escaping UserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't like moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't update current user")))
            return
        }
        
        APIService.performRequest(request: .updateUserFile(file: file, userId: currentUser.objectId, type: type.rawValue, oldURL: oldURL)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let user = try response.mapObject(User.self)
                    UserProvider.shared.currentUser = user
                    
                    completion(.success(user))
                }
                catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func loadEducationPlaces(completion: @escaping (Result<[String]>) -> Void) {
        
        guard UserProvider.shared.currentUser != nil else {
            return
        }
        
        guard isUserLoggedInFacebook() else {
            return
        }
        
        // try to fetch users' education info
        FBSDKGraphRequest(graphPath: "me", parameters: FacebookConstants.educationParameters).start { (connection, result, error) in
            
            guard error == nil else {
                completion(.failure(APIError(error: error!)))
                return
            }
            
            guard let result = result as? [String: Any] else {
                completion(.failure(APIError(code: 0, message: "No education places.")))
                return
            }
            
            let educationPlaces = parseAllEducationHistory(from: result)
            completion(.success(educationPlaces))
        }
    }
    
    class func loadWorkPlaces(completion: @escaping (Result<[String]>) -> Void) {
        
        guard UserProvider.shared.currentUser != nil else {
            return
        }
        
        guard isUserLoggedInFacebook() else {
            return
        }
        
        // try to fetch users' work info
        FBSDKGraphRequest(graphPath: "me", parameters: FacebookConstants.workParameters).start { (connection, result, error) in
            
            guard error == nil else {
                completion(.failure(APIError(error: error!)))
                return
            }
            
            guard let result = result as? [String: Any] else {
                completion(.failure(APIError(code: 0, message: "No work places.")))
                return
            }
            
            let workPlaces = parseAllWorkHistory(from: result)
            completion(.success(workPlaces))
        }
    }
    
    class func getUserWithStatus(for searchedUserId: String, completion: @escaping UserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't like moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't like moment without current user")))
            return
        }
        
        APIService.performRequest(request: .getUserWithStatus(currentUserId: currentUser.objectId, searchedUserId: searchedUserId)) { (result) in
            switch result {
            case .success(let response):

                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let user = try response.mapObject(User.self)
                    completion(.success(user))
                }
                catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func report(user: User, completion: @escaping EmptyCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't report moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't report moment without current user")))
            return
        }
        
        APIService.performRequest(request: .reportUser(reporterId: currentUser.objectId, reportedId: user.objectId)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                completion(.success())
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func getMutualFriends(for user: User, completion: @escaping MutualFriendsCompletion) {
        
        guard isUserLoggedInFacebook() else {
            completion(.failure(APIError(code: 0, message: "User are not logged in Facebook.")))
            return
        }
        
        // load mutual facebook friends first
        let token = FBSDKAccessToken.current()!.tokenString
        loadMutualFacebookFriends(facebookId: user.facebookId ?? "", token: token!) { (result) in
            
            switch (result) {
            case .success(let users):
                
                loadFacebookUsers(allUsers: users, completion: { (result) in
                    
                    switch (result) {
                    case .success(let users):

                        let sortedUsers = users.sorted(by: { (user1: User, user2: User) -> Bool in
                            return user1.displayName < user2.displayName
//                            if user1.facebookId != nil && user2.facebookId != nil {
//                                return user1.displayName < user2.displayName
//                            } else {
//                                if user1.facebookId != nil {
//                                    return true
//                                } else if user2.facebookId != nil {
//                                    return false
//                                } else {
//                                    return user1.displayName < user2.displayName
//                                }
//                            }
                        })
                        
                        completion(.success(users.count, sortedUsers))
                        break
                    case .failure(let error):
                        completion(.failure(APIError(error: error)))
                        break
                    default:
                        break
                    }
                })
                break
            case .failure(let error):
                completion(.failure(error))
                break
            default:
                break
            }
        }
    }
    
    class func loadFacebookUsers(allUsers: [User], completion: @escaping (Result<[User]>) -> Void) {
        
        let ids = allUsers.filter({ $0.facebookId != nil }).map({ $0.facebookId! })
        
        guard ids.count > 0 else {
            completion(.success(allUsers))
            return
        }
        
        APIService.performRequest(request: .getFacebookFriends(facebookIds: ids)) { (result) in
            switch(result) {
            case .success(let response):
                do {
                    
                    let appUsers = try response.mapArray(User.self)
                    let usedIds = appUsers.map({ $0.facebookId! })
                    let filteredUsers = allUsers.filter({
                        if $0.facebookId == nil {
                            return true
                        } else {
                            return !usedIds.contains($0.facebookId!)
                        }
                    })
                    let totalUsers = appUsers + filteredUsers
                    
                    completion(.success(totalUsers))
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    class func loadFacebookUsers(with ids: [String], completion: @escaping (Result<[User]>) -> Void) {
        
        guard ids.count > 0 else {
            completion(.success([User]()))
            return
        }
        
        APIService.performRequest(request: .getFacebookFriends(facebookIds: ids)) { (result) in
            switch(result) {
            case .success(let response):
                do {
                    let users = try response.mapArray(User.self)
                    completion(.success(users))
                } catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }

    // MARK: - Private methods
    
    fileprivate class func loadMutualFacebookFriends(facebookId: String, token: String, completion: @escaping (Result<([User])>) -> Void) {
        
        APIService.performRequest(request: .mutualFriends(facebookId: facebookId, token: token)) { (result) in
            switch (result) {
            case .success(let response):
                
                do {
                    if let facebookItems = try response.mapJSON() as? [[String: Any]] {
                        let fakeUsers = facebookItems.map({ return User(fakeUserJSON: $0) })
                        
                        completion(.success(fakeUsers))
                    } else {
                        
                        completion(.failure(APIError(code: 0, message: "Can't parse facebook result data.")))
                    }
                } catch (let error) {
                    
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }


    fileprivate class func parseEducationHistory(from dict: [String: Any]) -> String? {
        var educationInfo: String? = nil
        
        if let educationDataArray = dict["education"] as? [[String: Any]] {
            
            if let currentStudyPlace = educationDataArray.filter({ $0["year"] == nil }).first {
                
                // name
                if let schoolDict = currentStudyPlace["school"] as? [String: Any], let  name = schoolDict["name"] as? String {
                    educationInfo = name
                }
            } else {
                if let sortedStudyDict = educationDataArray.sorted(by: { (dict1: [String : Any], dict2: [String : Any]) -> Bool in
                    
                    var year1: Int? = nil
                    var year2: Int? = nil
                    
                    if let year1Dict = dict1["year"] as? [String: Any], let _year1 = year1Dict["name"] as? String {
                        year1 = Int(_year1) ?? 0
                    }
                    
                    if let year2Dict = dict2["year"] as? [String: Any], let _year2 = year2Dict["name"] as? String {
                        year2 = Int(_year2) ?? 0
                    }
                    
                    if year1 != nil && year2 != nil {
                        return year1! > year2!
                    } else {
                        if year1 != nil {
                            return true
                        } else {
                            return false
                        }
                    }
                }).first {
                    if let schoolDict = sortedStudyDict["school"] as? [String: Any], let name = schoolDict["name"] as? String {
                        educationInfo = name
                    }
                }
            }
        }
        
        return educationInfo
    }
    
    fileprivate class func parseAllEducationHistory(from dict: [String: Any]) -> [String] {
        
        var educationPlaces = [String]()
        
        if let educationDataArray = dict["education"] as? [[String: Any]] {
            
            for educationDict in educationDataArray {
                var educationInfo = ""
                
                // name
                if let schoolDict = educationDict["school"] as? [String: Any], let  name = schoolDict["name"] as? String {
                    educationInfo = name
                }
                
                // year
                if let yearDict = educationDict["year"] as? [String: Any], let  year = yearDict["name"] as? String {
                    if educationInfo.numberOfCharactersWithoutSpaces() > 0 {
                        educationInfo += ", \(year)"
                    }
                }
                
                if educationInfo.numberOfCharactersWithoutSpaces() > 0 {
                    educationPlaces.append(educationInfo)
                }
            }
        }
        
        return educationPlaces
    }
    
    fileprivate class func parseAllWorkHistory(from dict: [String: Any]) -> [String] {
        
        var workPlaces = [String]()
        
        if let workDataArray = dict["work"] as? [[String: Any]] {
            
            for workDict in workDataArray {
                var workInfo = ""
                
                // position
                if let postionDict = workDict["position"] as? [String: Any], let  position = postionDict["name"] as? String {
                    workInfo = position
                }
                
                // employer
                if let employerDict = workDict["employer"] as? [String: Any], let employer = employerDict["name"] as? String {
                    if workInfo.numberOfCharactersWithoutSpaces() > 0 {
                        workInfo += " at \(employer)"
                    } else {
                        workInfo = employer
                    }
                }
                
                if workInfo.numberOfCharactersWithoutSpaces() > 0 {
                    workPlaces.append(workInfo)
                }
            }
        }
        
        return workPlaces
    }
    
    fileprivate class func parseWorkHistory(from dict: [String: Any]) -> String? {
        var workInfo: String? = nil
        
        if let workDataArray = dict["work"] as? [[String: Any]] {
            if let lastWorkPlace = workDataArray.filter({ $0["end_date"] == nil }).first {
                
                // position
                if let postionDict = lastWorkPlace["position"] as? [String: Any], let  position = postionDict["name"] as? String {
                    workInfo = position
                }
                
                // employer
                if let employerDict = lastWorkPlace["employer"] as? [String: Any], let employer = employerDict["name"] as? String {
                    if workInfo != nil && workInfo!.numberOfCharactersWithoutSpaces() > 0 {
                        workInfo! += " at \(employer)"
                    } else {
                        workInfo = employer
                    }
                }
            } else {
                for workDict in workDataArray {
                    
                    // position
                    if let postionDict = workDict["position"] as? [String: Any], let  position = postionDict["name"] as? String {
                        workInfo = position
                    }
                    
                    // employer
                    if let employerDict = workDict["employer"] as? [String: Any], let employer = employerDict["name"] as? String {
                        if workInfo != nil && workInfo!.numberOfCharactersWithoutSpaces() > 0 {
                            workInfo! += " at \(employer)"
                        } else {
                            workInfo = employer
                        }
                    }
                    
                    if workInfo != nil && workInfo!.numberOfCharactersWithoutSpaces() > 0 {
                        break
                    }
                }
            }
        }
        
        return workInfo
    }
    
    fileprivate class func updateUsersInfo() {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            return
        }
        
        guard isUserLoggedInFacebook() else {
            return
        }
        
        // try to fetch users' work/education info
        FBSDKGraphRequest(graphPath: "me", parameters: FacebookConstants.shortParameters).start { (connection, result, error) in
            
            guard error == nil else {
                return
            }
            
            // parse data
            if let result = result as? [String: Any] {
                var wasChanged = false
                
                if let workPlace = parseWorkHistory(from: result) {
                    currentUser.workInfo = workPlace
                    wasChanged = true
                }
                
                if let educationPlace = parseEducationHistory(from: result) {
                    currentUser.studyInfo = educationPlace
                    wasChanged = true
                }
                
                if wasChanged {
                    UserProvider.updateUser(user: currentUser, completion: nil)
                }
            }
        }
    }
    
    fileprivate class func createUser(user: User, completion: @escaping (Result<User>) -> Void) {
        
        let provider = APIService.APIProvider()
        provider.request(.createNewUser(newUser: user)) { (result) in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else {
                    logout()
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    // parse auth token
                    shared.authToken = try response.mapString(atKeyPath: JSONKeys.jwt)
                    
                    let newUser = try response.mapObject(User.self)
                    
                    shared.currentUser = newUser
                    completion(.success(newUser))
                }
                catch (let error) {
                    completion(.failure(APIError(error: error)))
                }
                break
            case .failure(let error):
                completion(.failure(APIError(error: error)))
                break
            }
        }
    }
    
    fileprivate class func fetchUserInfoFromFacebook(completion: @escaping (Result<User>) -> Void) {
    
        FBSDKGraphRequest(graphPath: "me", parameters: FacebookConstants.parameters).start { (connection, result, error) in
            
            if error != nil {
                CLSNSLogv("ERROR: Error issuing graph request: %@", getVaList([error as! CVarArg]))
                completion(.failure(APIError(error: error!)))
                return
            }
            
            if let result = result as? [String: Any] {
                guard let id = result["id"] as? String, let name = result["name"] as? String else {
                    CLSNSLogv("ERROR: FB Info bad format", getVaList([]))
                    completion(.failure(APIError(code: 0, message: "Unable to retrieve info from Facebook")))
                    return
                }
                
                // email/gender
                let email = result["email"] as? String ?? ""
                var gender = Gender.Man
                
                if let genderStr = result["gender"] as? String, let fbGender = Gender(rawValue: genderStr) {
                    gender = fbGender
                }
                
                // profile image
                var profileImageURL: String?
                if let pictureDict = result["picture"] as? [String: Any], let data = pictureDict["data"] as? [String: Any] {
                    profileImageURL = data["url"] as? String
                    print("user has profile image: \(profileImageURL)")
                }
                
                // work
                let workInfo = parseWorkHistory(from: result) ?? ""
                
                // education
                let educationInfo = parseEducationHistory(from: result) ?? ""
                
                // profile pictures
                var profilePicturesURLs = [String]()
                if let albumsDict = result["albums"] as? [String: Any], let albums = albumsDict["data"] as? [[String: Any]] {
                    for album in albums {
                        if album["name"] as? String == "Profile Pictures" {
                            if let photosDict = album["photos"] as? [String: Any], let photosData = photosDict["data"] as? [[String: Any]] {
                                let limit = min(Configurations.General.photosCountToLoadAtStart, photosData.count)
                                for i in 0 ..< limit {
                                    if let images = photosData[i]["images"] as? [[String: Any]], let firstImage = images.first, let sourceURL = firstImage["source"] as? String {
                                        profilePicturesURLs.append(sourceURL)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // create user to hold all this information
                let user = User(objectId: "-1", facebookId: id, displayName: name, email: email, gender: gender, profileImageURL: profileImageURL, workInfo: workInfo, studyInfo: educationInfo, uploadedURLs: profilePicturesURLs, lastActiveDate: Date())
                user.location = LocationManager.shared.currentLocationCoordinates
                
                // birthday
                do {
                    let birthdateFormatter = DateFormatter()
                    birthdateFormatter.dateFormat = "MM/dd/yyyy"
                    
                    if let birthday = result["birthday"] as? String {
                        if let birthDate = birthdateFormatter.date(from: birthday) {
                            let birthComponents = Calendar.current.dateComponents([.year], from: birthDate)
                            
                            if birthComponents.year == NSDateComponentUndefined {
                                throw UserProvider.LoginError.noBirthday
                            } else {
                                user.age = birthDate.age
                                print("user has \(user.age) years")
                            }

                            completion(.success(user))
                        } else {
                            throw UserProvider.LoginError.noBirthday
                        }
                    } else {
                        throw UserProvider.LoginError.noBirthday
                    }
                } catch {
                    DatePickerDialog().show("Birthday", doneButtonTitle: "Done", datePickerMode: UIDatePickerMode.date) {
                        (date) -> Void in
                        user.age = date.age
                        print("user has \(user.age) years")
                        completion(.success(user))
                    }
                }
            } else {
                CLSNSLogv("ERROR: FB Info bad format", getVaList([]))
                completion(.failure(APIError(code: 0, message: "Unable to retrieve info from Facebook")))
            }
        }
    }
}
