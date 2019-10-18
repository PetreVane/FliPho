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
    internal var photoID: String
    internal var photoSecret: String
    internal var photoServer: String
    internal var photoFarm: Int
    internal let title: String
    internal var imageUrl: URL?
    internal var comments: [CommentData]?
    
    // optional photoRecord properties
    internal var latitude: Double?
    internal var longitude: Double?
    
    internal var image = UIImage(named: "Flickr image")
    internal var state = PhotoRecordState.new
    
    
     init(identifier: String, secret: String, server: String, farm: Int, title: String) {
        
        self.photoID = identifier
        self.photoSecret = secret
        self.photoServer = server
        self.photoFarm = farm
        self.title = title
        self.imageUrl = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(identifier)_\(secret)_c.jpg")
    }
    
}




