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

class UserProvider: NSObject {
    
    // MARK: - Types
    
    enum LoginError : Error {
        case noBirthday
    }
    
    struct Constants {
        static let facebookPermissions = ["public_profile", "email", "user_photos", "user_birthday", "user_friends", "user_education_history", "user_work_history"/*, "user_events"*/]
    }
    
    // MARK: - Properties
    
    static let shared = UserProvider()
    
    var currentUser: User?
    
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
        //TODO: load user by its facebook id
        guard let facebookId = FBSDKAccessToken.current().userID else {
            print("Error: Can't load user without normal token")
            completion?(.failure("Your current session is expired. Please login."))
            return
        }
        
        print("Facebook Id = \(facebookId)")
        
        shared.currentUser = User.test()
        completion?(.success(User.test()))
    }
    
    class func logInUser(with location: CLLocation?, from controller: UIViewController, completion: @escaping ((Result<User>) -> Void)) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .web
        loginManager.logIn(withReadPermissions: Constants.facebookPermissions, from: controller) { (result, error) in
        
            guard error == nil else {
                CLSNSLogv("ERROR: Error logging into Facebook: %@", getVaList([error! as CVarArg]))
                completion(.failure(error!.localizedDescription))
                return
            }
            
            guard result != nil else {
                completion(.failure("No result"))
                return
            }
            
            // try to load user by facebook id
            loadUser(completion: { (result) in
                switch result {
                case .success(let user): // reuse already created user
                    completion(result)
                    break
                case .failure(let message): // no user with such facebook id
                    fetchUserInfoFromFacebook(completion: { (result) in
                        switch(result) {
                        case .failure(let msg):
                            CLSNSLogv("ERROR: Unable to retrieve user details from Facebook: %@", getVaList([msg]))
                            completion(.failure(msg))
                            
                        case .success(let user):
                            BranchProvider.operateFirstEntrance(with: user)
                            
                            completion(.success(user))
                            break
                            /*
                             UserProvider.saveUserInInstallation(user)
                             user.lastActiveTime = Date()
                             
                             UserProvider.saveParseUser(user) { (result) in
                             
                             switch(result) {
                             case .failure(let msg):
                             CLSNSLogv("ERROR: Could not save user to Parse: %@", getVaList([msg]))
                             completion(.failure(msg))
                             
                             case .success:
                             
                             LayerManager.sharedManager.authenticateLayerWithUserID(user.objectId! as NSString, completion: { (success, error) in
                             
                             //TODO: Set it to new users only. below of pUser.isNew
                             self.matchWithSuperUser(user.objectId!)
                             //                                self.createChattingRoom()
                             if pUser.isNew {
                             
                             var nLocation = CLLocation(latitude: 0, longitude: 0)
                             if location != nil {
                             nLocation = location!
                             }
                             
                             let preferences = Preferences.createPreferences(lowerAgeRange: 18, upperAgeRange: 85, searchLocation: nLocation, searchDistance: CLLocationDistance(100), lookingFor: [Gender.Man.rawValue, Gender.Woman.rawValue, Gender.Couple.rawValue])
                             
                             PreferencesProvider.saveParseUserPrefs(preferences, user: user, completion: { result in
                             
                             switch (result) {
                             case .failure(let msg):
                             completion(.failure(msg))
                             case .success:
                             completion(Result<User>.success(user))
                             }
                             })
                             } else {
                             completion(.success(user))
                             }
                             })
                             }
                             }*/
                        }
                    })
                    break
                }
            })
        }
    }
    
//    private static func createChattingRoom() {
//        let superUserId = "WlsuoQxwUB"
//        LayerManager.sharedManager.authenticateLayerWithUserID(superUserId, completion: { (success, error) in
//            
//            //TODO: Set it to new users only. below of pUser.isNew
//            if success {
//                self.matchWithSuperUser((User.currentUser()?.objectId)!)
//            }
//            
//        })
//    }
    
    // MARK: - Private methods
    
    fileprivate class func fetchUserInfoFromFacebook(completion: @escaping (Result<User>) -> Void) {
        let parameters = ["fields" : "id, email, first_name, last_name, name, birthday, gender, work, education, picture.width(1000).height(1000), albums{photos.height(1000){images},name}"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            if error != nil {
                CLSNSLogv("ERROR: Error issuing graph request: %@", getVaList([error as! CVarArg]))
                completion(.failure(error!.localizedDescription))
                return
            }
            
            if let result = result as? [String: Any] {
                guard let id = result["id"] as? String, let name = result["name"] as? String else {
                    CLSNSLogv("ERROR: FB Info bad format", getVaList([]))
                    completion(.failure("Unable to retrieve info from Facebook"))
                    return
                }
                
                // email/gender
                let email = result["email"] as? String
                let gender = result["gender"] as? String
                
                // profile image
                if let pictureDict = result["picture"] as? [String: Any], let data = pictureDict["data"] as? [String: Any], let profileImageURL = data["url"] as? String {
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
                var profilePicturesURLs = [URL]()
                if let albumsDict = result["albums"] as? [String: Any], let albums = albumsDict["data"] as? [[String: Any]] {
                    for album in albums {
                        if album["name"] as? String == "Profile Pictures" {
                            if let photosDict = album["photos"] as? [String: Any], let photosData = photosDict["data"] as? [[String: Any]] {
                                let limit = min(Configurations.General.photosCountToLoadAtStart, photosData.count)
                                for i in 0 ..< limit {
                                    if let images = photosData[i]["images"] as? [[String: Any]], let firstImage = images.first, let sourceURL = firstImage["source"] as? String {
                                        profilePicturesURLs.append(URL(string: sourceURL)!)
                                    }
                                }
                            }
                        }
                    }
                }
                
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
                                let age = birthDate.age
                                print("user has \(age) years")
                            }
                            completion(.success(UserProvider.shared.currentUser!))
                        } else {
                            throw UserProvider.LoginError.noBirthday
                        }
                    } else {
                        throw UserProvider.LoginError.noBirthday
                    }
                } catch {
                    DatePickerDialog().show("Birthday", doneButtonTitle: "Done", datePickerMode: UIDatePickerMode.date) {
                        (date) -> Void in
                        let age = date.age
                        print("user has \(age) years")
                        completion(.success(UserProvider.shared.currentUser!))
                    }
                }
            } else {
                CLSNSLogv("ERROR: FB Info bad format", getVaList([]))
                completion(.failure("Unable to retrieve info from Facebook"))
                return
            }
        }
    }
    
    // MARK: SuperUser
    fileprivate func matchWithSuperUser(_ userId: String) {
        
        let params = ["userId" : userId]
        
//        PFCloud.callFunction(inBackground: ParseFunction.AddMatchSuperUser.name, withParameters: params, block: { (result, error) in
//            
//            if(error != nil) {
//                CLSNSLogv("ERROR: Unable to Follow SuperUser", getVaList([]))
//                return
//            }
//            
//            if let superUser = result as? String {
//
//                _ = LayerManager.conversationBetweenUser(superUser, andUserId: userId, message: LocalizableString.EnjoyBrizeo.localizedString)
//            }
//        })
    }
    
    fileprivate func saveUserInInstallation(_ user: User) {
//        guard let installation = PFInstallation.current() else {
//            print("No installation")
//            return
//        }
//        
//        installation["user"] = user
//        installation.saveInBackground()
    }
    
    fileprivate func saveParseUser(_ user: User, completion: @escaping (Result<Void>) -> Void) {
        
//        user.saveInBackground { (success, error) in
//            if(success) {
//                do {
//                    try User.current()?.fetch()
//                } catch(let error as NSError) {
//                    CLSNSLogv("ERROR: Unable to refresh current user: %@", getVaList([error]))
//                }
//                completion(.success())
//                
//            } else {
//                completion(.failure(error!.localizedDescription))
//            }
//        }
    }

    class func getMutualFriendsOfCurrentUser(_ currUser: User, andSecondUser secondUser: User, completion: @escaping (Result<[(name:String, pictureURL:String)]>) -> Void) {
        
        let currUserFBToken = FBSDKAccessToken.current()
        let currUserFBId = currUser.facebookId
        let secondUserFBId = secondUser.facebookId
        
        let userParams = ["id": currUserFBId, "token": currUserFBToken?.tokenString, "friend_id": secondUserFBId] as [String : Any]
        let params = ["user":userParams]
        
        print(currUser)
        print(secondUser)
        
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
                    completion(Result.failure(error.localizedDescription))
                    break
                }
        }
    }
    
    class func reportUser(_ reportedUser: User, user: User, completion: @escaping (Result<Bool>) -> Void) {
        
//        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, UserParameterKey.ReportedUserIdKey: reportedUser.objectId! as AnyObject]
//        PFCloud.callFunction(inBackground: ParseFunction.ReportUser.name, withParameters: params) { (result, error) in
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
    
    //MARK: Rewards
    class func sendDownloadEvent(_ user: User, timesDownloaded: Int, completion: @escaping (Result<Bool>) -> Void) {
        
//        let params : [String: AnyObject] = [UserParameterKey.UserIdKey : user.objectId! as AnyObject, UserParameterKey.totalKey: timesDownloaded as AnyObject]
//        PFCloud.callFunction(inBackground: ParseFunction.DownloadEvent.name, withParameters: params) { (result, error) in
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
