//
//  ChatItem.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class ChatItem{
    var from = ""
    var message = ""
    var date = 0.0
    var photo:Data?
    
    init(from:String,message:String,date:Double) {
        self.from = from
        self.message = message
        self.date = date
    }
    
    init(from:String,photo:Data,date:Double) {
        self.from = from
        self.photo = photo
        self.date = date
    }
}

func <(lhs: ChatItem, rhs: ChatItem) -> Bool{
    return lhs.date < rhs.date
}
