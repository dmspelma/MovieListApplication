//
//  User.swift
//  MovieList
//
//  Created by Drew Spelman on 4/16/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var email: String?
    var fullname: String?
    var username: String?
    var location: String?
    var profileurl: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.email = dictionary["email"] as? String
        self.fullname = dictionary["fullname"] as? String
        self.username = dictionary["username"] as? String
        self.location = dictionary["location"] as? String
        self.profileurl = dictionary["profileurl"] as? String
    }
}

class LikedMovies: NSObject {
    var id: String?
    var movieID: String?
    var like: Int?
    
    init(dictionary: [String: AnyObject]){
        self.id = dictionary["id"] as? String
        self.movieID = dictionary["movieID"] as? String
        self.like = dictionary["like"] as? Int
    }
}
