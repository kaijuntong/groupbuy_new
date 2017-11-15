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
    
    init(chatID:String, otherPersonUserID:String, lastMessage:String, date:Double) {
        self.chatID = chatID
        self.otherPersonUserID = otherPersonUserID
        self.lastMessage = lastMessage
        self.date = date
    }
}
