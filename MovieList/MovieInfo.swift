//
//  MovieInfo.swift
//  MovieList
//
//  Created by Drew Spelman on 3/22/18.
//  Copyright © 2018 Drew Spelman. All rights reserved.
//

import UIKit
import Foundation

struct MovieInfo: Decodable {
    let id: Int?
    let posterPath: String?
    let title: String?
    private enum CodingKeys: String, CodingKey {
        case id, posterPath = "poster_path", title
    }
}

struct MovieResults: Decodable {
    let page: Int?
    let numResults: Int?
    let numPages: Int?
    var movies: [MovieInfo]
    private enum CodingKeys: String, CodingKey {
        case page, numResults = "total_results", numPages = "total_pages",
        movies = "results"
    }
}

struct MovieData: Decodable {
    let id: Int?
    let posterPath: String?
    let backdrop: String?
    let the_title: String?
    let releaseDate: String?
    let rating: Double?
    let overview: String?
    let genres: [MovieGenre]
    private enum CodingKeys: String, CodingKey {
        case id, posterPath = "poster_Path", backdrop = "backdrop_path", the_title = "original_title", releaseDate =
            "release_date", rating = "vote_average", overview, genres
    }
}

struct MovieGenre: Decodable {
    let id: Int?
    let name: String?
}

class MovieSave: NSObject{
    var id: String?
    var title: String?
    var score: Int?
    
    init(dictionary: [String: AnyObject]){
        self.id = dictionary["id"] as? String
        self.title = dictionary["title"] as? String
        self.score = dictionary["score"] as? Int
    }
}

class MovieFav: NSObject{
    var id: String?
    var movieID: String?
    var fav: Bool?
    var title: String?
    var posterPath: String?
    
    init(dictionary: [String : AnyObject]){
        self.id = dictionary["id"] as? String
        self.movieID = dictionary["movieID"] as? String
        self.fav = dictionary["fav"] as? Bool
        self.title = dictionary["title"] as? String
        self.posterPath = dictionary["posterPath"] as? String
    }
}
