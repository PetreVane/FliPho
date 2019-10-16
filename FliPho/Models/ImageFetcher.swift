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
    
  unowned var photo: PhotoRecord
    
    init(photo: PhotoRecord) {
        self.photo = photo
    }
    
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        guard  photo.imageUrl != nil else { return } // throw an error here 
        if let imageData = try? Data(contentsOf: photo.imageUrl!) {

            if !imageData.isEmpty {
                photo.image = UIImage(data: imageData)
                photo.state = .downloaded

            } else {
                photo.image = nil
                photo.state = .failed
                print("Failed fetching image")
            }
        }
    }
}

