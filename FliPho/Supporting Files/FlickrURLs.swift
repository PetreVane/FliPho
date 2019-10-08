//
//  Flickr.swift
//  FliPho
//
//  Created by Petre Vane on 05/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


struct FlickrURLs {
    
    static func fetchUserInfo(userID: String) -> URL? {
    
        // flickr.people.getInfo
        
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=71d96734d24db3adf3fbc0560a24f1cf&user_id=\(userID)&format=json&nojsoncallback=1")
            else { return URL(string: "No user info url ")}
        
        return url
    }
    
    static func checkAuthToken(userID: String) -> URL? {
       
        // flickr.auth.oauth.checkToken
        
        guard let checkAuthURL = URL(string: "https://api.flickr.com/services/rest/?method=flickr.auth.oauth.checkToken&api_key=\(consumerKey)&user_id=\(userID)&per_page=250&page=&format=json&nojsoncallback=1")
            else { return URL(string: "no authentication url") }
        
        return checkAuthURL
        
    }
    
    static func fetchInterestingPhotos() -> URL? {
        
        // flickr.interestingness.getList

        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=\(consumerKey)&per_page=250&page=&format=json&nojsoncallback=1")
            else { return URL(string: "No valid url for flickr.interestingness.getList ")
        }
//        print("Interesting url: \(url.absoluteString)")
        return url
    }
    
    static func fetchUserPhotos(userID: String) -> URL? {
        
        // flickr.people.getPhoto
        
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.people.getPhotos&api_key=\(consumerKey)&user_id=\(userID)&per_page=250&page=&format=json&nojsoncallback=1")
            else { return URL(string: "no valid url for flickr.people.getPhoto ") }
//        print("FetchUserPhotos: \(url.absoluteString)")
        return url
    }
    
    static func fetchPhotosFromCoordinates(latitude: Double, longitude: Double) -> URL? {
        
        // flickr.photos.search
        
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(consumerKey)&accuracy=11&has_geo=1&lat=\(latitude)&lon=\(longitude)&radius=5&radius_units=km&per_page=&format=json&nojsoncallback=1")
            else { return URL(string: "No valid url for flickr.photos.search with location coordinates") }
        
        return url
    }
    
    static func fetchPhotoCoordinates(photoID: String) -> URL? {
        
        // flickr.photos.geo.getLocation
        
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=\(consumerKey)&photo_id=\(photoID)&format=json&nojsoncallback=1")
            else { return URL(string: "No valid url for flickr.photos.geo.getLocation") }
        
        return url
    }
    
}
