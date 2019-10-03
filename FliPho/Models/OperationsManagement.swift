//
//  OperationsManagement.swift
//  FliPho
//
//  Created by Petre Vane on 09/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


protocol OperationsManagement {
    
    // these protocol methods help with the process of starting / stopping image fetching, when the user scrolls / stopped scrolling the tableView / collectionView
    // please see the implementation in each ViewController file
     
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath)
    
    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath)
    
    func suspendOperations()
    
    func resumeOperations()
    
}



