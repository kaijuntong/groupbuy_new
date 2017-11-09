//
//  Orderlist.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 08/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class Orderlist{
    var orderDate = 0.0
    var paymentPrice = 0.0
    var key = ""
    
    init(key:String, orderDate:Double, paymentPrice:Double) {
        self.key = key
        self.orderDate = orderDate
        self.paymentPrice = paymentPrice
    }
    
}
