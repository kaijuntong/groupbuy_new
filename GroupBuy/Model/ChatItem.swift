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
    
    init(from:String,message:String,date:Double) {
        self.from = from
        self.message = message
        self.date = date
    }
}
