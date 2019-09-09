//
//  ImageFetcher.swift
//  FliPho
//
//  Created by Petre Vane on 02/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation
import UIKit


class ImageFetcher: Operation {
    
    var photo: PhotoRecord
    
    init(photo: PhotoRecord) {
        self.photo = photo
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        guard let imageData = try? Data(contentsOf: photo.imageUrl) else { return }
        
        if !imageData.isEmpty {
            
            photo.image = UIImage(data: imageData)
//            photo.state = .downloaded
            
        } else {
            
            photo.image = UIImage(named: "Could not fetch image")
            photo.state = .failed
            print("Failed fetching image")
        }
    }
    
}

