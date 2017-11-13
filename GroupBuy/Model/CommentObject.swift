//
//  CommentObject.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 02/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class CommentObject{
    var username:String = ""
    var comment:String = ""
    var date:String = ""
    var rate:Int = 0
    var submitDate:Double = 0.0
    
    
    init(username:String, comment:String) {
        self.username = username
        self.comment = comment
    }
    
    init(username:String, comment:String, rate:Int) {
        self.username = username
        self.comment = comment
        self.rate = rate
    }

    init(username:String, comment:String, rate:Int, submitDate:Double) {
        self.username = username
        self.comment = comment
        self.rate = rate
        self.submitDate = submitDate
    }

    
}
