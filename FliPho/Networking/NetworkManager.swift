//
//  NetworkManager.swift
//  FliPho
//
//  Created by Petre Vane on 22/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation


class NetworkManager {
    

//    typealias completion = (Data?, NetworkManagerError?) -> Void
    typealias result = (Result<Data, NetworkManagerError>) -> Void
        
    func fetchData(from url: URL, completionWith: @escaping result) {
                
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { completionWith(.failure(.failedRequest))
                return
            }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200 else { completionWith(.failure(.unexpectedResponse))
                    return
            }
            
            guard let receivedData = data else { completionWith(.failure(.missingData))
                return
            }
            completionWith(.success(receivedData))

        } .resume()
    }
}

enum NetworkManagerError: Error {
    
    case failedRequest
    case unexpectedResponse
    case missingData
    case unknownError
    
   var localizedDescription: String {
        
        switch self {
        case .failedRequest:
            return "Server unreachable. Connect to internet and try again"
        case .unexpectedResponse:
            return "Server responded with unexpected status code"
        case .missingData:
            return "Missing of corrupt data"
        default:
            return "Unknown error; default case"
        }
    }
}





