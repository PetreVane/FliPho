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
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        switch photoRecord.state {
        case .new:
            startDownload(for: photoRecord, indexPath: indexPath)
        case .downloaded:
            stopDownload(for: photoRecord, indexPath: indexPath)
        default:
            print("FeedsVC: StartOperations() default case")
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
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                print("ImageFetcher completed task for index \(indexPath)")
            }
            
        }
        
        pendingOperations.downloadInProgress[indexPath] = imageFetching
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
    }
    
    func stopDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        imageFetching.completionBlock = {
            
            if imageFetching.isFinished {
                return
            }
            
            DispatchQueue.main.async {
                photoRecord.state = .downloaded
                print("StopDownload: imageFetching finished at index \(indexPath.row)")
            }
        }
        
    }
    
    func suspendOperations() {
        
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeOperations() {
        
        pendingOperations.downloadQueue.isSuspended = false
    }
    
}
