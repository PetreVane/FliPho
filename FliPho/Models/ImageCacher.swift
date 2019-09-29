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
    
    private let cache = NSCache<NSString, UIImage>()
    var photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        
        if isCancelled {
            return
        }
        guard photoRecord.state == .downloaded else { return }
        
//        saveImageToCache(record: photoRecord, key: photoRecord.imageUrl.absoluteString)
        
    }
    
    func saveImageToCache(record: PhotoRecord, key: String) {
           
           guard record.state == .downloaded else { return }
           guard let image = record.image else { return }
           
           cache.setObject(image, forKey: key as NSString)
           
           record.state = .cached
       }
       
       func retrieveFromCache(key: String) -> UIImage? {
           
        var retrievedImage: UIImage?
        if let image = cache.object(forKey: key as NSString) {
            retrievedImage = image
            print("Success retrieving image from cache")
            
        }
        
//        if image != nil {
//            print("Retrieved image is NOT nil")
//        }
           return retrievedImage
       }
    
    
    
    
    
    // MARK: - Experimenting with FileManager
    
    
//    let fileManager = FileManager.default
//    let temporaryDirectoryURL = FileManager.default.temporaryDirectory
//    let documentsDirectoryURL = FileManager.documentsDirectoryURL
    
    
//    enum SavingLocation {
//
//        case temporaryDirectory
//        case documentsDirectory
//    }
    
//    enum CachingError: Error {
//
//        case missingData
//        case failedSavingData
//        case failedRemovingData
//        case failedFetchingData
//    }
    
//    func saveImage(record: PhotoRecord, at location: SavingLocation) throws {
//
//        guard let imageData = record.image?.pngData() else { throw CachingError.missingData }
//
//        switch location {
//
//        case .documentsDirectory:
//            let savedDirectoryPath = documentsDirectoryURL.appendingPathComponent("SavedFlickrImages", isDirectory: true)
//            try? fileManager.createDirectory(at: savedDirectoryPath, withIntermediateDirectories: true, attributes: nil)
//            try imageData.write(to: savedDirectoryPath.appendingPathComponent(record.name).appendingPathExtension("png"), options: .atomic)
//
//
//        case .temporaryDirectory:
//            let cachedDirectoryPath = temporaryDirectoryURL.appendingPathComponent("CachedFlickrImages", isDirectory: true)
//            try? fileManager.createDirectory(at: cachedDirectoryPath, withIntermediateDirectories: true, attributes: nil)
//            try imageData.write(to: cachedDirectoryPath.appendingPathComponent(record.name).appendingPathExtension("png"), options: .atomic)
//        }
//
//    }
        
//    func removeItems(from location: SavingLocation) throws {
//
//        if temporaryDirectoryURL.hasDirectoryPath {
//            try fileManager.removeItem(at: temporaryDirectoryURL)
////            print("Deleted content of temp directory: \(temporaryDirectoryURL.absoluteString)")
//
//        }
//    }
    
//    func fetchItems(from location: SavingLocation) {
//
//        if temporaryDirectoryURL.hasDirectoryPath {
//            if #available(iOS 13.0, *) {
//                do {
//                    let items = try FileManager.default.contentsOfDirectory(at: temporaryDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//
//                    for item in items.enumerated() {
//                        let image = try Data(contentsOf: item.element)
//                        print(image.description)
//                    }
//
//                } catch {
//                    print("Errors while reading from temporaryDirectory: \(error.localizedDescription)")
//                }
//
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//
//    }
    
}

