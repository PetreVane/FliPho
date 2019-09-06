//
//  PhotoRecord.swift
//  FliPho
//
//  Created by Petre Vane on 02/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation
import UIKit

enum PhotoRecordState {
    
    case new
    case downloaded
    case failed
}

class PhotoRecord {
    
    let name: String
    let imageUrl: URL
    var latitude: Double?
    var longitude: Double?
    var image = UIImage(named: "Flickr image")
    var state = PhotoRecordState.new
    
    
    init(name: String, imageUrl: URL) {
        self.name = name
        self.imageUrl = imageUrl
        
    }
    
}

