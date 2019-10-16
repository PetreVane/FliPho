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
    case failed
}

class PhotoRecord {
    
    // essential photoRecord properties
    internal let photoID: String
    internal var photoSecret: String?
    internal var photoServer: String?
    internal var photoFarm: Int?
    internal let title: String
    internal let imageUrl: URL
    
    // optional photoRecord properties
    internal var latitude: Double?
    internal var longitude: Double?
    
    internal var image = UIImage(named: "Flickr image")
    internal var state = PhotoRecordState.new
    
    
    
    init(title: String, imageUrl: URL, photoID: String) {
        
        self.title = title
        self.imageUrl = imageUrl
        self.photoID = photoID
    }
    
}




