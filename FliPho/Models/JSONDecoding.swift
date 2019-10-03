//
//  JSONDecoding.swift
//  FliPho
//
//  Created by Petre Vane on 02/10/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

protocol JSONDecoding {
    
    func decodeJSON<T: Codable>(from data: Data, decodingModel: T.Type) -> Result<T, Error>
}

