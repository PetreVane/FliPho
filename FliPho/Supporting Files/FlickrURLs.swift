//
//  Flickr.swift
//  FliPho
//
//  Created by Petre Vane on 05/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


struct FlickrURLs {
    
    static func checkAuthToken(apiKey: String, userID: String) -> URL? {
       
        // flickr.auth.oauth.checkToken
        guard let checkAuthURL = URL(string: "https://api.flickr.com/services/rest/?method=flickr.auth.oauth.checkToken&api_key=\(apiKey)&user_id=\(userID)&per_page=250&page=&format=json&nojsoncallback=1") else
        { print("Failed getting the Authentication URL")
            return URL(string: "no authentication url") }
        
        return checkAuthURL
        
    }
    
    static func fetchInterestingPhotos(apiKey: String) -> URL? {
        
        // flickr.interestingness.getList
        var url: URL?
        if let urlFromString = URL(string: "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=\(apiKey)&per_page=250&page=&format=json&nojsoncallback=1") {
            url = urlFromString
        }
        
        return url
    }
    
    static func fetchUserPhotos(apiKey: String, userID: String) -> URL? {
        
        // flickr.people.getPhoto
        
        var url: URL?
        
        if let urlFromString = URL(string: "https://api.flickr.com/services/rest/?method=flickr.people.getPhotos&api_key=\(apiKey)&user_id=\(userID)&per_page=250&page=&format=json&nojsoncallback=1") {
            url = urlFromString
        }
        return url
    }
    
    static func fetchPhotosFromCoordinates(apiKey: String, latitude: Double, longitude: Double) -> URL? {
        
        // flickr.photos.search
        
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&accuracy=11&has_geo=1&lat=\(latitude)&lon=\(longitude)&radius=5&radius_units=km&per_page=20&format=json&nojsoncallback=1") else
        { print("Failed getting url for photos with location coordinates")
            return URL(string: "No url for photos from location")
        }
        
        
        return url
    }
    
    static func fetchPhotosCoordinates(apiKey: String, photoID: String) -> URL? {
        
        // flickr.photos.geo.getLocation
        
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=\(apiKey)&photo_id=\(photoID)&format=json&nojsoncallback=1") else { print("Failed casting flickr.photos.geo.getLocation as url")
            return URL(string: "flickr.photos.geo.getLocation")
        }
        return url
    }
    
}
