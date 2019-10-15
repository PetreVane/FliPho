//
//  JSON.swift
//  FliPho
//
//  Created by Petre Vane on 23/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

//MARK: - Protocol declaration

protocol JSONDecoding {
    // the generic parameter (model: T) eases the process of calling this method with different JSON decoding models, which are declared below
    // the Result type also contains a generic parameter, because each decoding model returns an object of a diferent type
    func decodeJSON<T: Decodable>(model: T.Type, from data: Data) -> Result<T, Error>
}

        
   // MARK: -  Decoding Model for User info
    
struct DecodedUserInfo: Codable {

    let person: Person

    struct Person: Codable {
        
        let id, nsid: String
        let ispro, canBuyPro: Int
        let iconserver: String
        let iconfarm: Int
        let hasStats: String

        
        enum CodingKeys: String, CodingKey {
            
            case id, nsid, ispro
            case canBuyPro = "can_buy_pro"
            case iconserver, iconfarm
            case hasStats = "has_stats"
        }
    }
}
    
    // MARK: - Decoding Model for Geographic Coordinates of Pictures
    
struct DecodedGeoData: Codable {

    let photo: Photo
    
    struct Photo: Codable {
        
        let id: String
        let location: Location
    }

    struct Location: Codable {
        
        let latitude: String
        let longitude: String
    }
}

    // MARK: - Decoding Model for Image URLs
    
struct DecodedPhotos: Codable {
    
    let photos: Photos
    
}

    
struct Photos: Codable {
    
    let photo: [Photo]

    enum CodingKeys: String, CodingKey {
        
        case photo
    }
    
  
    
struct Photo: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        
        }
    }
}

    //MARK: -  Decoding Model for Photo Comments

struct DecodedPhotoComments: Codable {

    let comments: Comments
}



struct Comments: Codable {
    
    let photoID: String
    let comment: [Comment]

    enum CodingKeys: String, CodingKey {
        case photoID = "photo_id"
        case comment
    }
}

struct Comment: Codable {
    
    let id, author: String
    let authorIsDeleted: Int
    let authorname, iconserver: String
    let iconfarm: Int
    let datecreate: String
    let permalink: String
    let realname, content: String

    enum CodingKeys: String, CodingKey {
        
        case id, author
        case authorIsDeleted = "author_is_deleted"
        case authorname, iconserver, iconfarm, datecreate, permalink
        case realname
        case content = "_content"
    }
}




