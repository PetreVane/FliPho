//
//  FileManagerExtension.swift
//  FliPho
//
//  Created by Petre Vane on 28/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

extension FileManager {
    
    static var documentsDirectoryURL: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
