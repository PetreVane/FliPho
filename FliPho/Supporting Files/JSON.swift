//
//  JSON.swift
//  FliPho
//
//  Created by Petre Vane on 23/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


struct JSON: Codable {
    
    
   // MARK: - Decoding User info
    
    struct EncodedUserInfo: Codable {
        
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
    
    // MARK: - Decoding Geographic Coordinates of Pictures
    
    struct EncodedGeoData: Codable {

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

    // MARK: - Decoding Image URLs
    
    struct EncodedPhotos: Codable {
        
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
}
