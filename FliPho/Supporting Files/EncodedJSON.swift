//
//  EncodedJSON.swift
//  FliPho
//
//  Created by Petre Vane on 02/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


struct EncodedJSON: Codable {
    
    let photos: Photos
    
}
    
struct Photos: Codable {

    let photo: [Photo]


    enum CodingKeys: String, CodingKey {

        case photo
    }
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


