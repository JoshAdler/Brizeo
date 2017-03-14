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
        static let permissions = ["public_profile", "email", "user_photos", "user_birthday", "user_friends", "user_education_history", "user_work_history"/*, "user_events"*/]
        static let parameters = ["fields" : "id, email, first_name, last_name, name, birthday, gender, work, education, picture.width(1000).height(1000), albums{photos.height(1000){images},name}"]
    }

    typealias UserCompletion = (Result<User>) -> Void
    typealias EmptyCompletion = (Result<Void>) -> Void
    
    // MARK: - Properties
    
    static let shared = UserProvider()
    
    var currentUser: User?
    var needToSaveChanges: Bool = false
    
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
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        shared.currentUser = nil
    }
    
    class func loadUser(completion: ((Result<User>) -> Void)?) {

        guard let facebookId = FBSDKAccessToken.current().userID else {
            print("Error: Can't load user without normal token")
            completion?(.failure(APIError.unknown(message: "Your current session is expired. Please login.")))
            return
        }
        
        // load user by facebook id
        let provider = MoyaProvider<APIService>()
        provider.request(.getCurrentUser(facebookId: facebookId/*"0"*/)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let user = try response.mapObject(User.self)
                    
                    shared.currentUser = user
                    completion?(.success(user))
                    
                    // load preferences
                    PreferencesProvider.loadPreferences(for: user.objectId, fromCache: false, completion: nil)
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
        
        let provider = MoyaProvider<APIService>()
        provider.request(.updateUser(user: user)) { (result) in
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion?(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                shared.currentUser = user
                shared.needToSaveChanges = true
                completion?(.success(user))
                print("successfully updated user info")
                
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
        loginManager.loginBehavior = .web
        loginManager.logIn(withReadPermissions: FacebookConstants.permissions, from: controller) { (result, error) in
        
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
                                    CLSNSLogv("ERROR: Unable to retrieve user details from Facebook: %@", getVaList([error as CVarArg]))
                                    completion(.failure(error))
                                    break
                                case .success(let user):
                                    shared.currentUser = user
                                    
                                    // load preferences
                                    PreferencesProvider.loadPreferences(for: user.objectId, fromCache: false, completion: nil)
                                    
                                    BranchProvider.operateFirstEntrance(with: user)
                                    ChatProvider.createChatWithSuperuser()
                                    
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
    
    class func updateUserFile(file: FileObject?, type: UpdateFileType, oldURL: String?, completion: EmptyCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't like moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't update current user")))
            return
        }
        
        
    }
    
    class func getUserWithStatus(for searchedUserId: String, completion: @escaping UserCompletion) {
        
        guard let currentUser = UserProvider.shared.currentUser else {
            print("Error: Can't like moment without current user")
            completion(.failure(APIError(code: 0, message: "Can't like moment without current user")))
            return
        }
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getUserWithStatus(currentUserId: currentUser.objectId, searchedUserId: searchedUserId)) { (result) in
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
        
        let provider = MoyaProvider<APIService>()
        provider.request(.reportUser(reporterId: currentUser.objectId, reportedId: user.objectId)) { (result) in
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

    // MARK: - Private methods
    
    fileprivate class func createUser(user: User, completion: @escaping (Result<User>) -> Void) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.createNewUser(newUser: user)) { (result) in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else {
                    logout()
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let userId = try response.mapString()
                    user.objectId = userId
                    
                    shared.currentUser = user
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
                let email = result["email"] as? String ?? "no_email"
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
                var workInfo = ""
                if let workDataArray = result["work"] as? [[String: Any]] {
                    for workData in workDataArray {
                        if let employerDict = workData["employer"] as? [String: Any], let employerName = employerDict["name"] as? String {
                            workInfo.append("\(employerName), ")
                        } else if let positionDict = workData["position"] as? [String: Any], let positionName = positionDict["name"] as? String {
                            workInfo.append("\(positionName), ")
                        }
                    }
                    
                    // remove ', ' in the end
                    if workInfo.numberOfCharactersWithoutSpaces() > 0 {
                        let endIndex = workInfo.index(workInfo.endIndex, offsetBy: -2)
                        workInfo = workInfo.substring(to: endIndex)
                    }
                }
                
                // education
                var educationInfo = ""
                if let educationDataArray = result["education"] as? [[String: Any]] {
                    for educationData in educationDataArray {
                        if let educationPlaceDict = educationData["school"] as? [String: Any], let educationPlaceName = educationPlaceDict["name"] as? String {
                            educationInfo.append("\(educationPlaceName), ")
                        }
                    }
                    
                    // remove ', ' in the end
                    if educationInfo.numberOfCharactersWithoutSpaces() > 0 {
                        let endIndex = educationInfo.index(educationInfo.endIndex, offsetBy: -2)
                        educationInfo = educationInfo.substring(to: endIndex)
                    }
                }
                
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
    
    class func getMutualFriendsOfCurrentUser(_ currUser: User, andSecondUser secondUser: User, completion: @escaping (Result<[(name:String, pictureURL:String)]>) -> Void) {

        
        return
        /*
        let currUserFBToken = FBSDKAccessToken.current()
        let currUserFBId = currUser.facebookId
        let secondUserFBId = "734396810046847"//secondUser.facebookId
        
        let userParams = ["id": currUserFBId, "token": currUserFBToken?.tokenString, "friend_id": secondUserFBId] as [String : Any]
        let params = ["user":userParams]
        
        Alamofire.request(Configurations.AppURLs.BrizeoCheckURL, method: .post, parameters: params)
            .validate()
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    
                    var friendsInfo = [(name:String, pictureURL:String)]()
                    if let json = value as? [[String: AnyObject]] {
                        for friend in json {
                            if  let name = friend["name"] as? String,
                                let userId = friend["id"] as? String {
                                
                                let pictureURL = "https://graph.facebook.com/\(userId)/picture?type=large&return_ssl_resource=1"
                                friendsInfo.append((name: name, pictureURL: pictureURL))
                            }
                        }
                    }
                    completion(.success(friendsInfo))
                    break
                case .failure(let error):
                    debugPrint(error)
                    completion(Result.failure(APIError(error: error)))
                    break
                }
        }*/
    }
    
    class func removeMatch(_ user: User, target: User, completion: @escaping (Result<Bool>) -> Void) {
        
//        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, UserParameterKey.TargetUserIdKey: target.objectId! as AnyObject]
//        PFCloud.callFunction(inBackground: ParseFunction.RemoveMatch.name, withParameters: params) { (result, error) in
//            
//            if let error = error {
//                
//                completion(.failure(error.localizedDescription))
//                
//            } else {
//                
//                completion(.success(true))
//            }
//        }
    }
}
