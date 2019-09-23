//
//  EncodedUserInfo.swift
//  FliPho
//
//  Created by Petre Vane on 21/09/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

// MARK: - UserInfo

struct UserInfo: Codable {
    
    let person: Person
}

// MARK: - Person

struct Person: Codable {
    
    let id, nsid: String
    let ispro, canBuyPro: Int
    let iconserver: String
    let iconfarm: Int
    let hasStats: String

    
    enum CodingKeys: String, CodingKey {
        
        case id, nsid, ispro
        case canBuyPro = "can_buy_pro"
        case iconserver, iconfarm
        case hasStats = "has_stats"
    }
}


