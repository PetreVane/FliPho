//
//  FileManager.swift
//  FliPho
//
//  Created by Petre Vane on 17/10/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

extension FileManager {
    
    static var documentsDirectory: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
