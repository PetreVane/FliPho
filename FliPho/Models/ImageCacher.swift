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
    
//    let photoRecord: PhotoRecord
    private let cache = NSCache<NSString, UIImage>()
    
//    init(photoRecord: PhotoRecord) {
//        self.photoRecord = photoRecord
//    }
    
//    convenience override init() {
//        self.init()
//    }
    
    
    override func main () {
        
        if isCancelled {
            return
        }
        

        
    }
    
    func saveImageToCache(record: PhotoRecord, imageURL: String) {
        
        guard let image = record.image else { return }
        cache.setObject(image, forKey: record.imageUrl.absoluteString as NSString)
        record.state = .cached
    }
    
    func retrieveImageFromCache(imageURL: String) -> UIImage? {
        
        guard let imageFromCache = cache.object(forKey: imageURL as NSString) else { return nil }
        
        return imageFromCache
    }
    
}

