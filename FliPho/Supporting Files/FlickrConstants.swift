//
//  FlickrConstants.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation
import OAuthSwift


let defaults = UserDefaults()

// segue identifiers
let mainMenu = "mainMenu"

// MARK: Constants
struct Constants {
    
    static var userID: String?
    static let consumerKey = "11ba962b3f2d30ee51503e7320929d65"
    static let consumerSecret = "92e51d0a3248e2a2"
    
    static let requestTokenURL = "https://www.flickr.com/services/oauth/request_token"
    static let authorizationURL = "https://www.flickr.com/services/oauth/authorize"
    static let accessTokenURL = "https://www.flickr.com/services/oauth/access_token"
    
}

// MARK: Flick API Methods
enum APIMethod: String {
    
    typealias RawValue = String
    
    case isCheckOauthToken = "flickr.auth.oauth.checkToken"
    case isInterestingPhotos = "flickr.interestingness.getList"
    case isUserPhotoActivity = "flickr.activity.userPhotos"
    case isGetPhotos = "flickr.people.getPhotos"
    case isGetPhotosForLocation = "flickr.photos.geo.photosForLocation"
    case isPhotoSearch = "flickr.photos.search"
}


// MARK: Flick URL Constructor
struct URLBase {
    
    static let Scheme = "https"
    static let Host = "api.flickr.com"
    static let Path = "/services/rest/"
    
}

struct URLKeys {
    
    static let apiMethod = "method"
    static let apiKey = "api_key"
    static let userId = "user_id"
    static let apiFormat = "format"
    static let jsonCallBack = "nojsoncallback"
    static let text = "text"
    static let perPage = "per_page"
    static let page = "page"
    static let authToken = "auth_token"
    
}

struct URLValues {
    
    static let apiKey = Constants.consumerKey
    static let userId = Constants.userID
    static let apiFormat = "json"
    static let jsonCallBack = "1"
    static let perPage = "250"
    static let page = ""
    
}

struct Flickr {
    
    static func apiEndPoint(where method: APIMethod) -> String {
        
        let userNSID = defaults.value(forKey: "user_nsid") as? String
        
        var urlComponents = URLComponents()
        
        // URL Base
        urlComponents.scheme = URLBase.Scheme
        urlComponents.host = URLBase.Host
        urlComponents.path = URLBase.Path
        
        // URL Parameters
        urlComponents.queryItems = [URLQueryItem]()
        
        urlComponents.queryItems?.append(URLQueryItem.init(name: URLKeys.apiMethod, value: method.rawValue))
        urlComponents.queryItems?.append(URLQueryItem(name: URLKeys.apiKey, value: URLValues.apiKey))
        urlComponents.queryItems?.append(URLQueryItem(name: URLKeys.userId, value: userNSID))
        urlComponents.queryItems?.append(URLQueryItem(name: URLKeys.perPage, value: URLValues.perPage))
        urlComponents.queryItems?.append(URLQueryItem(name: URLKeys.page, value: URLValues.page))
        urlComponents.queryItems?.append(URLQueryItem(name: URLKeys.apiFormat, value: URLValues.apiFormat))
        urlComponents.queryItems?.append(URLQueryItem(name: URLKeys.jsonCallBack, value: URLValues.jsonCallBack))
        
//        print(urlComponents.string!)

        return urlComponents.string!
    }
}
