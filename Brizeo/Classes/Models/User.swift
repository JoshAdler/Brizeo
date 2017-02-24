//
//  User.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/18/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Parse
import Crashlytics
import Branch
import Atlas
import LayerKit

// MARK: - Gender

enum Gender: String {
    case Man = "male"
    case Woman = "female"
    case Couple = "couple"
    
    static func gender(for index: Int) -> Gender {
        switch index {
        case 0:
            return .Man
        case 1:
            return .Woman
        default:
            return .Couple
        }
    }
    
    var title: String {
        switch self {
        case .Man:
            return "Man"
        case .Woman:
            return "Woman"
        case .Couple:
            return "Couple"
        }
    }
    
    static var defaultGender: Gender {
        return .Couple
    }
}

struct UserParameterKey {
    static let UserIdKey = "userId"
    static let ReportedUserIdKey = "reportedUserId"
    static let TargetUserIdKey = "targetId"
    static let totalKey = "total"
}

struct UserParseKey {
    static let FacebookId = "facebookId"
    static let ObjectId = "objectId"
    static let Email = "email"
    static let Username = "displayName"
    static let Interests = "interests"
    static let ProfileText = "personalText"
    static let Age = "age"
    static let Gender = "gender"
    static let CurrentLocation = "location"
    static let LastActiveTime = "lastActiveTime"
    static let UploadedMedia = "uploadImages"
    static let ProfileImage = "profileImage"
    static let SuperUser = "superUser"
}

// MARK: - User

class User: PFUser {
    
    // MARK: - Properties
    
    @NSManaged var displayName: String
    @NSManaged var facebookId: String
    @NSManaged var gender: String?
    @NSManaged var age: Int
    @NSManaged var interests: [String]
    @NSManaged var location: PFGeoPoint?
    @NSManaged var personalText: String
    @NSManaged var lastActiveTime: Date?
    @NSManaged var profileImage: PFFile
    @NSManaged var uploadImages: [[String : AnyObject]]?
    @NSManaged var countries: [String]
    @NSManaged var superUser: Bool
    @NSManaged var workInfo: String?
    @NSManaged var studyInfo: String?
    
    var genderValue: Gender {
        get {
            if let genderString = gender, let value = Gender(rawValue: genderString) {
                return value
            }
            return Gender.defaultGender
        }
        set {
            gender = newValue.rawValue
        }
    }
    
    // RB: for testings
    var uploadedImages: [URL] {
        return [
            URL(string: "https://pbs.twimg.com/profile_images/378800000367201581/5fdde49e2b1d0793499a92ac8a2401f8_400x400.jpeg")!,
            URL(string: "http://data.whicdn.com/images/31140261/original.jpg")!,
            URL(string: "http://susers.thatsmyface.com/m/mario_chalmers/Eminem_left_0aDkVpabI2-largeThumb_f227a7ca.jpg")!
        ]
//        var images = [URL]()
//        let urls = [
//            URL(string: "https://pbs.twimg.com/profile_images/378800000367201581/5fdde49e2b1d0793499a92ac8a2401f8_400x400.jpeg"),
////            URL(string: "http://data.whicdn.com/images/31140261/original.jpg"),
////            URL(string: "http://susers.thatsmyface.com/m/mario_chalmers/Eminem_left_0aDkVpabI2-largeThumb_f227a7ca.jpg"),
//            URL(string: "http://cdn.singersroom.com/wp-content/uploads/2016/01/eminemtalksimpressingrickrubinovercomingdrugaddiction.jpg"),
//            URL(string: "http://gdtmedia.india.com/data/topics/image/0/16580/6e6b82d49222985afb638caf2bead855_225X300_1.jpg"),
//            URL(string: "https://www.looktothestars.org/photo/145-eminem/story_half_width.jpg")
//        ]
//        let random = Int(arc4random_uniform(5))
//        for i in 0 ..< random {
//            images.append(urls[i]!)
//        }
        
        //return images
    }
    
    var profileImageUrl: URL? {
        if let profileMediaType = uploadedMedia.first, let urlString = ProfileMediaTypePreviewUrl(profileMediaType) {
            return URL(string: urlString)
        }
        //TODO:
        return URL(string: "http://peerie.adaptive.net/faces/full/3/10585-152656.jpg")//nil
    }
    
    var uploadedMedia: [ProfileMediaType] {
        var tempFiles = [ProfileMediaType]()
        
        if let uploadImages = uploadImages {
            for media in uploadImages {
                tempFiles += [PFFileToProfileMediaType(media)]
            }
        }
        
        return tempFiles
    }
    
    // MARK: - Class methods
    
    class func test() -> User {
        let uuid = UUID().uuidString
        let user = createUser(uuid, userName: "Roman", interests: ["travel"], age: 27, profileText: "Some text about me", uploadedMedia: [], gender: "male", currentLocation: nil, lastActiveTime: nil, fbID: "12312313", isSuperUser: false)
        
        user.studyInfo = "University of Rochester"
        user.workInfo = "Medical/Health"
        user.location = PFGeoPoint(latitude: 5.5, longitude: 5.5)
        
        return user
    }
    
    class func createUser(_ id: String, userName: String, interests: [String], age: Int, profileText: String, uploadedMedia: [ProfileMediaType], gender: String?, currentLocation: CLLocation?, lastActiveTime: Date?, fbID: String, isSuperUser: Bool) -> User {
        
        let user = User()
        
        user.objectId = id
        user.displayName = userName
        user.interests = interests
        user.age = age
        user.personalText = profileText
        user.uploadImages = User.profileMediaToParse(uploadedMedia)
        user.gender = gender
        user.location = PFGeoPoint(location: currentLocation)
        user.lastActiveTime = lastActiveTime
        user.facebookId = fbID
        user.superUser  = isSuperUser
        user.countries = ["AC", "AD"]
        
        return user
    }
    
    class func getUsers(_ userIds: [String], completion: @escaping ([User]?, NSError?) -> Void) {
    
        let query = PFUser.query()!
        
        query.whereKey("objectId", containedIn: userIds)
        query.findObjectsInBackground { objects, error in
            let users = objects as? [User]
            completion(users, error as NSError?)
        }
    }
    
    class func getMyMomentCount(_ userId: String) -> Int {
        var count = 0
        let query = PFQuery(className: "MomentImages")
        query.whereKey("user", equalTo: userId)
        query.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                print(objects?.count)
                count = (objects?.count)!
                
            } else{
                print(error)
            }
        })
        return count
    }
    
    class func matchQuery(_ userId: String) -> PFQuery<PFObject> {
        let queryA = PFQuery(className: "Match")
        queryA.whereKey("userB", equalTo: userId)
        let queryMatchA = PFUser.query()
        queryMatchA!.whereKey("objectId", matchesKey: "userA", in: queryA)
        let queryB = PFQuery(className: "Match")
        queryB.whereKey("userA", equalTo: userId)
        let queryMatchB = PFUser.query()
        queryMatchB!.whereKey("objectId", matchesKey: "userB", in: queryB)
        return PFQuery.orQuery(withSubqueries: [queryMatchA!, queryMatchB!])
    }
    
    class func matchQueryAlt(_ userId: String, mode: Int) -> PFQuery<PFObject> {
        var queryMatch: PFQuery<PFObject>
        switch mode {
        case 0:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            query.order(byDescending: "objectId")
            query.addDescendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 1:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            query.order(byAscending: "objectId")
            query.addDescendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 2:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            query.order(byAscending: "objectId")
            query.addDescendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 3:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            query.order(byAscending: "objectId")
            query.addAscendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 4:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byDescending: "createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 5:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byAscending: "createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 6:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byDescending: "userA")
            query.addDescendingOrder("createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
        case 7:
            let query = PFQuery(className: "Match")
            query.whereKey("userB", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byAscending: "userA")
            query.addAscendingOrder("createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userA", in: query)
            break
            
        case 8:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            query.order(byDescending: "objectId")
            query.addDescendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 9:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            query.order(byAscending: "objectId")
            query.addDescendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 10:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            query.order(byAscending: "objectId")
            query.addDescendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 11:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            query.order(byAscending: "objectId")
            query.addAscendingOrder("createdAt")
            queryMatch = PFUser.query()!
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 12:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byDescending: "createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 13:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byAscending: "createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 14:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byDescending: "userB")
            query.addDescendingOrder("createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        case 15:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byAscending: "userB")
            query.addAscendingOrder("createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
        default:
            let query = PFQuery(className: "Match")
            query.whereKey("userA", equalTo: userId)
            queryMatch = PFUser.query()!
            query.order(byDescending: "createdAt")
            queryMatch.whereKey("objectId", matchesKey: "userB", in: query)
            break
            
        }
        
        return queryMatch
    }
    
    class func myQuery(_ userId: String) -> PFQuery<PFObject> {
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: userId)
        return query!
    }
    
    class func fromParseUser(_ pObject: [String : AnyObject]) -> User? {
        
        guard let userName = pObject[UserParseKey.Username] as? String,
            let age = pObject[UserParseKey.Age] as? Int,
            let fbID = pObject[UserParseKey.FacebookId] as? String,
            let id = pObject[UserParseKey.ObjectId] as? String  else {
                CLSNSLogv("Unable to create User. One of the four must haves was nil", getVaList([]))
                return nil
        }
        
        let interests = pObject[UserParseKey.Interests] as? [String] ?? []
        let lastMessageSendTime = pObject[UserParseKey.LastActiveTime] as? Date ?? nil
        let profileText = pObject[UserParseKey.ProfileText] as? String ?? ""
        let uploadedMediaRaw = pObject[UserParseKey.UploadedMedia] as? [[String : AnyObject]] ?? []
        let uploadedMedia = User.initializeProfileMedia(uploadedMediaRaw)
        let genderString = pObject[UserParseKey.Gender] as? String ?? ""
        let pLocation = pObject[UserParseKey.CurrentLocation] as? PFGeoPoint ?? nil
        let isSuperUser = pObject[UserParseKey.SuperUser] as? Bool ?? false
        var location: CLLocation?
        
        if let pLocation = pLocation {
            location = CLLocation(latitude: pLocation.latitude, longitude: pLocation.longitude)
        }
        
        return createUser(id, userName: userName, interests: interests, age: age, profileText: profileText, uploadedMedia: uploadedMedia, gender: genderString, currentLocation: location, lastActiveTime: lastMessageSendTime, fbID: fbID, isSuperUser: isSuperUser)
    }
    
    // MARK: CurrentUser
    class func userIsCurrentUser(_ user: User) -> Bool {
        
        if let currentUser = User.current() {
            
            return currentUser.objectId == user.objectId
        }
        return false
    }
    
    class func updateLastActiveTime() {
        
        if let currentUser = User.current() {
            
            currentUser.lastActiveTime = Date()
            User.saveParseUser({ (result) in
                
            })
        }
    }
    
    class func saveParseUser(_ completion: @escaping (Result<Void>) -> Void) {
        User.current()?.saveInBackground { (success, error) in
            if(success) {
                
                //                let priority = DispatchQueue.GlobalQueuePriority.default
                
                DispatchQueue.global().async {
                    // do some task
                    do {
                        try PFUser.current()?.fetch()
                        DispatchQueue.main.async {
                            completion(.success())
                        }
                        
                    } catch(let error as NSError) {
                        
                        DispatchQueue.main.async {
                            CLSNSLogv("ERROR: Unable to refresh current user: %@", getVaList([error]))
                            completion(.failure(error.localizedDescription))// update some UI
                        }
                    }
                }
                
                DispatchQueue.global()
                
            } else {
                completion(.failure(error!.localizedDescription))
            }
        }
    }
    
    // MARK: - Public methods
    
    func getDistanceString(_ toLocation: PFGeoPoint?) -> String? {
        
        guard let location = location else {
            return ""
        }
        
        let to = CLLocation(latitude: toLocation!.latitude, longitude: toLocation!.longitude)
        let from = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let distance = Int(to.distance(from: from) * Configurations.Dimentions.milesPerMeter)
        let distanceValue = distance < 1 ? 1 : distance
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        if distanceValue == 1 {
            return LocalizableString.OneMilesAway.localizedString
        } else {
            return LocalizableString.MilesAway.localizedStringWithArguments([formatter.string(from: NSNumber(value: distanceValue as Int))!])
        }
    }
    
    func getUserLocationString(_ completion:@escaping ((String) -> Void)) {
        if let location = location {
            let from = CLLocation(latitude: location.latitude, longitude: location.longitude)
            LocationManager().getLocationStringForLocation(from, completion: { (locationString) in
                completion(locationString)
            })
        }
    }
    
    func getActivityString() -> String? {
        
        guard let lastActiveTime = lastActiveTime else {
            
            return nil
        }
        
        return LocalizableString.ActiveTimeAgo.localizedStringWithArguments([minutesSinceLastActiveTime(lastActiveTime)])
    }
    
    func minutesSinceLastActiveTime(_ lastActiveTime: Date) -> String {
        
        var minutes = (Date() as NSDate).minute(since: lastActiveTime)
        if minutes < 0 {
            minutes = -minutes
        }
        if minutes > 60 {
            return hoursSinceLastActiveTime(lastActiveTime)
        } else {
            return LocalizableString.Minutes.localizedStringWithArguments([minutes])
        }
    }
    
    func hoursSinceLastActiveTime(_ lastActiveTime: Date) -> String {
        
        var hours = (Date() as NSDate).hours(since: lastActiveTime)
        if hours < 0 {
            hours = -hours
        }
        if hours > 24 {
            return daysSinceLastActiveTime(lastActiveTime)
        } else {
            return LocalizableString.Hours.localizedStringWithArguments([hours])
        }
    }
    
    func daysSinceLastActiveTime(_ lastActiveTime: Date) -> String {
        
        var days = (Date() as NSDate).days(since: lastActiveTime)
        if days < 0 {
            days = -days
        }
        return LocalizableString.Days.localizedStringWithArguments([days])
    }
    
    func weeksSinceLastActiveTime(_ lastActiveTime: Date) -> String {
        
        var weeks = (Date() as NSDate).weeks(since: lastActiveTime)
        if weeks < 0 {
            weeks = -weeks
        }
        if weeks > 4 {
            return monthsSinceLastActiveTime(lastActiveTime)
        } else {
            return LocalizableString.Weeks.localizedStringWithArguments([weeks])
        }
    }
    
    func monthsSinceLastActiveTime(_ lastActiveTime: Date) -> String {
        
        var months = (Date() as NSDate).months(since: lastActiveTime)
        if months < 0 {
            months = -months
        }
        if months > 12 {
            return yearsSinceLastActiveTime(lastActiveTime)
        } else {
            return LocalizableString.Months.localizedStringWithArguments([months])
        }
    }
    
    func yearsSinceLastActiveTime(_ lastActiveTime: Date) -> String {
        
        var years = (Date() as NSDate).years(since: lastActiveTime)
        if years < 0 {
            years = -years
        }
        return LocalizableString.Years.localizedStringWithArguments([years])
    }
    
    func addMediaAtIndex(_ media: ProfileMediaType, index: Int) {
        if let media = User.profileMediaToParse(media) {
            if uploadImages == nil {
                uploadImages = [[String : AnyObject]]()
            }
            
            if index < uploadImages!.count {
                uploadImages?[index] = media
            } else {
                uploadImages?.append(media)
            }
        }
    }
}

// MARK: - Private methods
extension User {

    fileprivate class func initializeProfileMedia(_ mediaInfo: [[String : AnyObject]]) -> [ProfileMediaType] {
        var array: [ProfileMediaType] = []
        for dictionary in mediaInfo {
            let item = PFFileToProfileMediaType(dictionary)
            array.append(item)
        }
        
        return array
    }
    
    fileprivate class func profileMediaToParse(_ media: ProfileMediaType) -> [String : AnyObject]? {
        
        switch(media) {
        case .empty:
            return nil
        default:
            let parseItem = ProfileMediaTypeToPFFile(media)
            return parseItem
        }
    }
    
    fileprivate class func profileMediaToParse(_ uploadedMedia: [ProfileMediaType]) -> [[String : AnyObject]] {
        
        var array = [[String : AnyObject]]()
        
        for media in uploadedMedia {
            if let item = profileMediaToParse(media) {
                array.append(item)
            }
        }
        
        return array
    }
}

// MARK: Rewards
extension User {
    
    class func checkUserRewards() {
        guard let currentUser = User.current() else {
            return
        }
        
        Branch.currentInstance.loadRewards { (changed, error) -> Void in
            let bucket = BranchKeys.InstallationBucket
            let credits = Branch.currentInstance.getCreditsForBucket(bucket)
            
            if credits > 0 && (credits % 50) == 0 {
                //send email every fifty downloads
                //started by referall
                UserProvider.sendDownloadEvent(currentUser, timesDownloaded: credits, completion: { (result) in
                    
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        //Error sending download event call
                        CLSNSLogv("ERROR: error occurred sending download event to api: %@", getVaList([error]))
                        break
                    }
                })
            }
        }
    }
}

// MARK: - ATLParticipant
extension User: ATLParticipant {
    
    var firstName: String {
        return displayName
    }
    
    var lastName: String {
        return ""
    }
    
    var userID: String {
        return objectId ?? ""
    }
    
    var avatarImageURL: URL? {
        return profileImageUrl as URL?
    }
    
    var avatarImage: UIImage? {
        return nil
    }
    
    var avatarInitials: String? {
        let firstInitial = firstName.characters.first ?? Character(" ")
        let lastInitial = lastName.characters.first ?? Character(" ")
        let initials = "\(firstInitial)\(lastInitial)"
        return initials.uppercased()
    }
    
    fileprivate func getFirstCharacter(_ value: String) -> String {
        return (value as NSString).substring(to: 1)
    }
}
