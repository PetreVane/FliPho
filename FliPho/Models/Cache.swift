//
//  Cache.swift
//  FliPho
//
//  Created by Petre Vane on 04/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

class Cache {
    
    let storage = NSCache<NSString, AnyObject>()
    
    func saveToCache(with key: NSString, value: AnyObject) {
        storage.setObject(value, forKey: key)
    }
    
    func retrieveFromCache(with key: NSString) -> AnyObject? {
        
        var result: AnyObject?
        
        if let objectFromCache = storage.object(forKey: key) {
            
            result = objectFromCache
            return result
        }
        
        return result
    }
    
}
