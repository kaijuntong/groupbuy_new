//
//  ChatListItem.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class ChatListItem{
    var otherPersonUserID = ""
    var lastMessage = ""
    var chatID = ""
    var date = 0.0
    var username = ""
    var otherPersonImage = ""
    var imageData:Data?
    
    init(chatID:String, otherPersonUserID:String, lastMessage:String, date:Double, username:String, otherPersonImage:String, imageData:Data?) {
        self.chatID = chatID
        self.otherPersonUserID = otherPersonUserID
        self.lastMessage = lastMessage
        self.date = date
        self.username = username
        self.otherPersonImage = otherPersonImage
        self.imageData = imageData
    }
    
}

func >(lhs: ChatListItem, rhs: ChatListItem) -> Bool{
    return lhs.date > rhs.date
}
