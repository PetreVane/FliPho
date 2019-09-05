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
        
        guard let checkAuthURL = URL(string: "https://api.flickr.com/services/rest/?method=flickr.auth.oauth.checkToken&api_key=\(apiKey)&user_id=\(userID)&per_page=250&page=&format=json&nojsoncallback=1") else
        { print("Failed getting the Authentication URL")
            return URL(string: "no authentication url") }
        
        return checkAuthURL
        
    }
    
    static func fetchInterestingPhotos(apiKey: String) -> URL? {
        
        var url: URL?
        if let urlFromString = URL(string: "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=\(apiKey)&per_page=250&page=&format=json&nojsoncallback=1") {
            url = urlFromString
        }
        
        return url
    }
    
    static func fetchUserPhotos(apiKey: String, userID: String) -> URL? {
        
        var url: URL?
        
        if let urlFromString = URL(string: "https://api.flickr.com/services/rest/?method=flickr.people.getPhotos&api_key=\(apiKey)&user_id=\(userID)&per_page=250&page=&format=json&nojsoncallback=1") {
            url = urlFromString
        }
        return url
    }
    
    static func fetchPhotosFromCoordinates(apiKey: String, latitude: Double, longitude: Double) -> URL? {
        
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.geo.photosForLocation&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&accuracy=11&format=json&nojsoncallback=1") else
        { print("Failed getting url for photos with location coordinates")
            return URL(string: "No url for photos from location")
        }
        
        return url
    }
}
