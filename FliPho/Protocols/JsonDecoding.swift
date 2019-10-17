//
//  JsonDecoding.swift
//  FliPho
//
//  Created by Petre Vane on 17/10/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

//MARK: - Protocol declaration

protocol JSONDecoding {
    
    // the generic parameter (model: T) eases the process of calling this method with different JSON decoding models, which are declared in JSON.swift
    // the Result type also contains a generic parameter, because each decoding model returns an object of a diferent type
    
    func decodeJSON<T: Decodable>(model: T.Type, from data: Data) -> Result<T, Error>
}
