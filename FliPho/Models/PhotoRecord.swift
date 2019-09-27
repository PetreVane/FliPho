//
//  PhotoRecord.swift
//  FliPho
//
//  Created by Petre Vane on 02/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation
import UIKit
import MapKit


enum PhotoRecordState {
    
    case new
    case downloaded
    case cached
    case failed
}

class PhotoRecord {
    
    let imageUrl: URL
    var latitude: Double?
    var longitude: Double?
    var image = UIImage(named: "Flickr image")
    var state = PhotoRecordState.new
    let name: String
    
    
    init(name: String, imageUrl: URL) {
        self.name = name
        self.imageUrl = imageUrl
        
    }
    
}

