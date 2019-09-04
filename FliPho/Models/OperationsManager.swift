//
//  OperationsManager.swift
//  FliPho
//
//  Created by Petre Vane on 04/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


class OperationsManager {
    
    // MARK: - Operations Management
    
    fileprivate let pendingOperations = PendingOperations()
    let storage = Cache()
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        switch photoRecord.state {
        case .new:
            startDownload(for: photoRecord, indexPath: indexPath)
        default:
            print("default case")
//        case .downloaded:
//            print("StartOperations: Image fetched and cached: \(indexPath.row)")
//        case .failed:
//            print("Image failed")

        }
        
    }
    
    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        guard photoRecord.state == .new else { return }
        
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        imageFetching.completionBlock = {
            
            if imageFetching.isCancelled {
                return
            }
            
            if imageFetching.isFinished{
                
                photoRecord.state = .downloaded
                self.storage.saveToCache(with: photoRecord.name as NSString, value: photoRecord as AnyObject)

            }
            
            self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
        }
        
        pendingOperations.downloadInProgress[indexPath] = imageFetching
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
    }
    
    
    func suspendOperations() {
        
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeOperations() {
        
        pendingOperations.downloadQueue.isSuspended = false
    }
    
}
