//
//  FlickrAnnotation.swift
//  FliPho
//
//  Created by Petre Vane on 16/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation
import MapKit


class FlickrAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
