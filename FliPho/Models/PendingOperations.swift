//
//  PendingOperations.swift
//  FliPho
//
//  Created by Petre Vane on 02/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

class PendingOperations {
    
    // Downloading
    lazy var downloadInProgress: [IndexPath: Operation] = [:]
    
    lazy var downloadQueue: OperationQueue = {
        
        var queue = OperationQueue()
        queue.name = "Flickr fetching queue"
        
        return queue
    }()
    
    // Caching
    lazy var cachingInProgress: [IndexPath: Operation] = [:]
    
    lazy var cachingQueue: OperationQueue = {
        
        var queue = OperationQueue()
        queue.name = "Caching Queue"
        
        return queue
    }()
    
}
