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
