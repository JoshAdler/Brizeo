//
//  APILayer.swift
//  Brizeo
//
//  Created by Roman Bayik on 3/5/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import Foundation
import Moya

enum APIService {
    // user
    case getCurrentUser(facebookId: String)
    case createNewUser(newUser: User)
    case updateUser(user: User)
    
    // preferences
    case getPreferences(userId: String)
    case updatePreferences(userId: String, preferences: Preferences)
    
    // moment
    case getMoments(userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String)
    case getAllMoments(sortingFlag: MomentsSortingFlag, filterFlag: String)
    case getMatchedMoments(userId: String, sortingFlag: MomentsSortingFlag, filterFlag: String)
    
    // country
    case addCountriesForUser(countries: [Country], userId: String)
    case deleteCountriesForUser(countries: [Country], userId: String)
}

extension APIService: TargetType {
    var baseURL: URL { return URL(string: Configurations.General.apiURL)! }
    
    var path: String {
        switch self {
        case .getCurrentUser(let facebookId):
            return "/users/\(facebookId)"
        case .createNewUser(_):
            return "/usres"
        case .updateUser(let user):
            return "/users/\(user.objectId)"
        case .getPreferences(let userId), .updatePreferences(let userId, _):
            return "/preferences/\(userId)"
        case .addCountriesForUser(_, let userId), .deleteCountriesForUser(_, let userId):
            return "/countries/\(userId)"
        case .getMoments(let userId, let sortingFlag, let filterFlag):
            return "/moments/\(userId)/\(sortingFlag.rawValue)/\(filterFlag)"
        case .getAllMoments(let sortingFlag, let filterFlag):
            return "/moments/\(sortingFlag.rawValue)/\(filterFlag)"
        case .getMatchedMoments(let userId, let sortingFlag, let filterFlag):
            return "/matchedmoments/\(userId)/\(sortingFlag.rawValue)/\(filterFlag)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCurrentUser(_), .getPreferences(_), .getMoments(_, _, _), .getAllMoments(_, _), .getMatchedMoments(_, _, _):
            return .get
        case .createNewUser(_):
            return .post
        case .updatePreferences(_, _), .updateUser(_), .addCountriesForUser(_, _):
            return .put
        case .deleteCountriesForUser(_, _):
            return .delete
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getCurrentUser(_), .getPreferences(_), .getMoments(_, _, _), .getAllMoments(_, _), .getMatchedMoments(_, _, _):
            return nil
        case .createNewUser(_):
            return nil
        case .updatePreferences(_, _):
            return nil
        case .updateUser(_):
            return nil
        case .addCountriesForUser(_):
            return nil
        case .deleteCountriesForUser(_, _):
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getCurrentUser(_), .getPreferences(_), .getMoments(_, _, _), .getAllMoments(_ ,_), .getMatchedMoments(_, _ ,_):
            return URLEncoding.default
        case .createNewUser(_), .updatePreferences(_, _), .updateUser(_), .addCountriesForUser(_, _), .deleteCountriesForUser(_, _):
            return JSONEncoding.default
        }
    }
    
    var sampleData: Data {
        return "No test data".utf8Encoded
//        switch self {
//        case .zen:
//            return "Half measures are as bad as nothing at all.".utf8Encoded
//        case .showUser(let id):
//            return "{\"id\": \(id), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".utf8Encoded
//        case .createUser(let firstName, let lastName):
//            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
//        case .updateUser(let id, let firstName, let lastName):
//            return "{\"id\": \(id), \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
//        case .showAccounts:
//            // Provided you have a file named accounts.json in your bundle.
//            guard let path = Bundle.main.path(forResource: "accounts", ofType: "json"),
//                let data = Data(base64Encoded: path) else {
//                    return Data()
//            }
//            return data
//        }
    }
    var task: Task {
        return .request
//        switch self {
//        case .getCurrentUser(_), .createNewUser(_), .getPreferences(_), .updatePreferences(_, _):
//            return .request
////        case .zen, .showUser, .createUser, .updateUser, .showAccounts:
////            return .request
//        }
    }
}
