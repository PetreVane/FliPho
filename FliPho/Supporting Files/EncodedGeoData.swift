//
//  EncodedGeoData.swift
//  FliPho
//
//  Created by Petre Vane on 05/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation




//struct EncodedGeoData: Codable {
//    let id: String
//    let location: Location
//}
//
//// MARK: - Location
//struct Location: Codable {
//    let latitude, longitude, accuracy: String
//}
//



struct Json: Codable {

struct EncodedGeoData: Codable {
    
    let photo: Photo
    let stat: String

}

    struct Photo: Codable {
        
        let id: String
        let location: Location
    }


    struct Location: Codable {
        
        let latitude: String
        let longitude: String

    }

}
