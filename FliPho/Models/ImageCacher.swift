//
//  ImageCacher.swift
//  FliPho
//
//  Created by Petre Vane on 27/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation
import UIKit


class ImageCacher: Operation {
    
    let photoRecord: PhotoRecord
    private let cache = NSCache<NSString, UIImage>()
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    
    override func main () {
        
        if isCancelled {
            return
        }
        
        guard let imageForCache = photoRecord.image else { return }
        saveImageToCache(image: imageForCache, imageURL: photoRecord.imageUrl.absoluteString)
        
    }
    
    func saveImageToCache(image: UIImage, imageURL: String) {
        
        cache.setObject(image, forKey: imageURL as NSString)
        photoRecord.state = .cached
    }
    
    func retrieveImageFromCache(imageURL: String) -> UIImage? {
        
        guard let imageFromCache = cache.object(forKey: imageURL as NSString) else { return nil }
        
        return imageFromCache
    }
    
}

