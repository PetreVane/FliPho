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
    
    
    enum SavingLocation {
        
        case temporaryDirectory
        case documentsDirectory
    }
    
    enum CachingError: Error {
        
        case missingPNGData
        case failedSavingData
    }
    
    func saveImage(record: PhotoRecord, at location: SavingLocation) throws {

        guard let imageData = record.image?.pngData() else { throw CachingError.missingPNGData }
        
        let fileManager = FileManager.default
        
        switch location {
            
        case .documentsDirectory:
            let directoryURL = FileManager.documentsDirectoryURL.appendingPathComponent("FlickrImages", isDirectory: true)
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            try imageData.write(to: directoryURL, options: .atomic)
            
        case .temporaryDirectory:
            let tempDirURL = FileManager.default.temporaryDirectory
            try? fileManager.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
            try imageData.write(to: tempDirURL, options: .atomic)
        }
        
    
    }
    
    override func main () {
        
        if isCancelled {
            return
        }
        
//        try saveImage(record: <#T##PhotoRecord#>, at: <#T##ImageCacher.SavingLocation#>)
        
    }
    
//    func saveImage(record: PhotoRecord) {
//
//        guard let imageData = record.image?.pngData() else { return }
//
////        try imageData.write(to: location, options: <#T##Data.WritingOptions#>)
//
//    }
    
    func saveImageToCache(record: PhotoRecord, imageURL: String) {
        
        guard let image = record.image else { return }
//        cache.setObject(image, forKey: record.imageUrl.absoluteString as NSString)
        record.state = .cached
    }

    
}

