//
//  CommentData.swift
//  FliPho
//
//  Created by Petre Vane on 15/10/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import Foundation

class CommentData {
    
    let id: String
    let authorNSID: String
    let authorName: String
    let iconServer: String
    let iconFarm: Int
    let commentDate: String
    let commentContent: String
    
    init(id: String, authorNSID: String, authorName: String, iconServer: String, iconFarm: Int, commentDate: String, commentContent: String) {
        
        self.id = id
        self.authorNSID = authorNSID
        self.authorName = authorName
        self.iconServer = iconServer
        self.iconFarm = iconFarm
        self.commentDate = commentDate
        self.commentContent = commentContent
    }
    
}

/*
 class User {
     
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
 */
