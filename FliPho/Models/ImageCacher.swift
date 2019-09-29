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
    
    let fileManager = FileManager.default
    let temporaryDirectoryURL = FileManager.default.temporaryDirectory
    let documentsDirectoryURL = FileManager.documentsDirectoryURL
    
    
    enum SavingLocation {
        
        case temporaryDirectory
        case documentsDirectory
    }
    
    enum CachingError: Error {
        
        case missingData
        case failedSavingData
        case failedRemovingData
        case failedFetchingData
    }
    
    func saveImage(record: PhotoRecord, at location: SavingLocation) throws {
        
        guard let imageData = record.image?.pngData() else { throw CachingError.missingData }
        
        switch location {
            
        case .documentsDirectory:
            let savedDirectoryPath = documentsDirectoryURL.appendingPathComponent("SavedFlickrImages", isDirectory: true)
            try? fileManager.createDirectory(at: savedDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            try imageData.write(to: savedDirectoryPath.appendingPathComponent(record.name).appendingPathExtension("png"), options: .atomic)
            
            
        case .temporaryDirectory:
            let cachedDirectoryPath = temporaryDirectoryURL.appendingPathComponent("CachedFlickrImages", isDirectory: true)
            try? fileManager.createDirectory(at: cachedDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            try imageData.write(to: cachedDirectoryPath.appendingPathComponent(record.name).appendingPathExtension("png"), options: .atomic)
        }
        
        
    }
    
    override func main () {
        
        if isCancelled {
            return
        }
                
    }
    
    func removeItems(from location: SavingLocation) throws {
        
        if temporaryDirectoryURL.hasDirectoryPath {
            try fileManager.removeItem(at: temporaryDirectoryURL)
            print("Deleted content of temp directory: \(temporaryDirectoryURL.absoluteString)")

        }
    }
    
    func fetchItems(from location: SavingLocation) {
        
        if temporaryDirectoryURL.hasDirectoryPath {
            if #available(iOS 13.0, *) {
                do {
                    let items = try FileManager.default.contentsOfDirectory(at: temporaryDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    
                    for item in items.enumerated() {
//                        print(item.element.absoluteString)
                        let image = try Data(contentsOf: item.element)
                        print(image.description)
                    }

                    
                } catch {
                    print("Errors while reading from temporaryDirectory: \(error.localizedDescription)")
                }
                
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
//    func saveImage(record: PhotoRecord) {
//
//        guard let imageData = record.image?.pngData() else { return }
//
////        try imageData.write(to: location, options: <#T##Data.WritingOptions#>)
//
//    }
    
//    func saveImageToCache(record: PhotoRecord, imageURL: String) {
//
//        guard let image = record.image else { return }
//        cache.setObject(image, forKey: record.imageUrl.absoluteString as NSString)
//        record.state = .cached
//    }

    
}

