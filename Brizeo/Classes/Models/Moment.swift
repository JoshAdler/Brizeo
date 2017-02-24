//
//  Moment.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 5/5/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import Parse

class Moment: PFObject, PFSubclassing {

    // MARK: - Properties
    
    @NSManaged var momentUploadImages: PFFile
    @NSManaged var user: User
    @NSManaged var numberOfLikes: Int
    @NSManaged var timesReported: Int
    @NSManaged var momentDescription: String
    @NSManaged var likedByCurrentUser : Bool
    @NSManaged var readStatus: Bool
    
    var imageUrl: URL? {
        
        if let urlString = momentUploadImages.url {
            return URL(string: urlString)
        }
        return nil
    }

    // MARK: - Static methods
    
    static func parseClassName() -> String {
        return "MomentImages"
    }
    
    // MARK: - Override methods
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Moment else { return false }
        
        return object.objectId == objectId
    }
    
    // MARK: - Class methods
    
    class func query(_ paginator: PaginationHelper) -> PFQuery<PFObject> {
        let query = PFQuery(className: Moment.parseClassName())
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        query.skip = paginator.totalElements
        query.limit = 20
        return query
    }
    
    class func queryMost(_ paginator: PaginationHelper) -> PFQuery<PFObject> {
        let query = PFQuery(className: Moment.parseClassName())
        query.includeKey("user")
        query.order(byDescending: "numberOfLikes")
        query.skip = paginator.totalElements
        query.limit = 20
        return query
    }
}
