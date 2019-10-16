//
//  UserModel.swift
//  FliPho
//
//  Created by Petre Vane on 16/10/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

class UserModel {
    
    let userNSID: String
    let userName: String
    var realName: String?
    let iconServer: String
    let iconFarm: Int
    var iconURL: URL?
    
    init(userID: String, userName: String, iconServer: String, iconFarm: Int) {
        self.userNSID = userID
        self.userName = userName
        self.iconServer = iconServer
        self.iconFarm = iconFarm
        self.iconURL = URL(string: "http://farm\(self.iconFarm).staticflickr.com/\(self.iconServer)/buddyicons/\(self.userNSID)_l.jpg")
    }
}

