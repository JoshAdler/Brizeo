//
//  EventsProvider.swift
//  Brizeo
//
//  Created by Mobile on 1/5/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import Foundation
import Crashlytics
import SwiftyUserDefaults
import FBSDKShareKit
import Moya
import CoreLocation
import FormatterKit

extension DefaultsKeys {
    static let lastEventsUpdate = DefaultsKey<Date?>("lastEventsUpdate")
}

class EventsProvider {

    // MARK: - Types
    
    typealias EventsCompletion = (Result<[Event]>) -> Void
    
    // MARK: - Class methods
    
    class func updateUserEventsIfNeeds() {
        
        guard UserProvider.shared.currentUser != nil else {
            print("no current user")
            return
        }
        
        guard UserProvider.isUserLoggedInFacebook() else {
            print("current user is not logged in Facebook")
            return
        }
        //TODO: check it
        /*
        // update each 24 hours
        if Defaults[.lastEventsUpdate] != nil && Defaults[.lastEventsUpdate]!.isInSameDayOf(date: Date()) {
            print("Don't need to update")
            return
        }*/
        
        fetchUserEventsFromFacebook { (result) in
            switch(result) {
            case .success(let events):
                
                let provider = MoyaProvider<APIService>()
                provider.request(.saveEvents(events: events)) { (result) in
                    
                    switch result {
                    case .success(_):
                        
                        Defaults[.lastEventsUpdate] = Date()
                        break
                    case .failure(_):
                        break
                    }
                }
                break
            case .failure(_):
                
                break
            default:
                break
            }
        }
    }
    
    class func getEvents(contentType type: EventsContentType, sortingFlag: SortingFlag, location: CLLocationCoordinate2D, completion: @escaping EventsCompletion) {
        
        if type == .all {
            getAllEvents(sortingFlag: sortingFlag, location: location, completion: completion)
        } else {
            getMatchedEvents(sortingFlag: sortingFlag, location: location, completion: completion)
        }
    }
    
    class func getAllEvents(sortingFlag: SortingFlag, location: CLLocationCoordinate2D, completion: @escaping EventsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getEvents(sortFlag: sortingFlag.APIPresentation, longitude: location.longitude, latitude: location.latitude)) { (result) in
            
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let events = try response.mapArray(Event.self)
                    completion(.success(events))
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
    
    class func getMatchedEvents(sortingFlag: SortingFlag, location: CLLocationCoordinate2D, completion: @escaping EventsCompletion) {
        
        let provider = MoyaProvider<APIService>()
        provider.request(.getMatchedEvents(userId: UserProvider.shared.currentUser!.objectId, sortFlag: sortingFlag.APIPresentation, longitude: location.longitude, latitude: location.latitude)) { (result) in
            
            switch result {
            case .success(let response):
                
                guard response.statusCode == 200 else {
                    completion(.failure(APIError(code: response.statusCode, message: nil)))
                    return
                }
                
                do {
                    let events = try response.mapArray(Event.self)
                    completion(.success(events))
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
    
    // MARK: - Private methods
    
    
    fileprivate class func fetchUserEventsFromFacebook(completion: @escaping (Result<[Event]>) -> Void) {
        
        guard UserProvider.isUserLoggedInFacebook() else {
            completion(.failure(APIError(code: 0, message: "Error: Can't fetch data from Facebook because user is not logged in.")))
            return
        }
        
        FBSDKGraphRequest(graphPath: "me", parameters: UserProvider.FacebookConstants.eventParameters).start { (connection, result, error) in
            
            if error != nil {
                CLSNSLogv("ERROR: Error issuing graph request: %@", getVaList([error as! CVarArg]))
                completion(.failure(APIError(error: error!)))
                return
            }
            
            guard let baseResult = result as? [String: Any], let eventsData = baseResult["events"] as? [String: Any], let eventsArray = eventsData["data"] as? [[String: Any]] else {
                completion(.failure(APIError(code: 0, message: "Error: Can't parse data from Facebook.")))
                return
            }
            
            // filter events to get only attended by current user
            /*let attendedEvents = eventsArray.filter({
                if let status = $0["rsvp_status"] as? String {
                    return status == "attending"
                }
                return false
            })*/
            let attendedEvents = eventsArray
            
            var events = [Event]()
            for eventData in attendedEvents {
                
                // start date
                var startDate: Date? = nil
                if let startDateStr = eventData["start_time"] as? String, let date = Helper.convertFacebookStringToDate(string: startDateStr) {
                    startDate = date
                }
                
                if startDate == nil || startDate!.isInPast {
                    continue
                }
                
                // is cancelled
                if let isCancelledString = eventData["is_canceled"] as? Bool {
                    if isCancelledString == true {
                        continue
                    }
                }
                
                // location
                var longitude: Double? = nil
                var latitude: Double? = nil
                
                if let place = eventData["place"] as? [String: Any], let location = place["location"] as? [String: Any] {
                    latitude = location["latitude"] as? Double
                    longitude = location["longitude"] as? Double
                }
                
                if longitude == nil || latitude == nil {
                    continue
                }
                
                let name = eventData["name"] as? String
                let description = eventData["description"] as? String
                let id = eventData["id"] as! String
                
                // cover
                var coverUrl: String?
                if let coverDict = eventData["cover"] as? [String: Any], let url = coverDict["source"] as? String {
                    coverUrl = url
                }
                
                // attending count & persons
                let attendingCount = eventData["attending_count"] as? Int
                var attendingIds: [String]?
                
                if let attendingUsersDict = eventData["attending"] as? [String: Any], let
                    
                    attendingUsers = attendingUsersDict["data"] as? [[String: String]] {
                    attendingIds = attendingUsers.map({ $0["id"]! })
                }
                
                // combine data into new event object
                let event = Event(facebookId: id, name: name, information: description, latitude: latitude, longitude: longitude, imageLink: coverUrl, attendingsCount: attendingCount, startDate: startDate, attendingIds: attendingIds)
                events.append(event)
            }
            
            completion(.success(events))
        }
    }
}
