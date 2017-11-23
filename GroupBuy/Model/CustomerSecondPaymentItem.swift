//
//  CustomerSecondPaymentItem.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 23/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation
class CustomerSecondPaymentItem{
    var status = ""
    var trackingNum = ""
    var curriorCompany = ""
    var weight = ""
    var price = ""
    var sellerEmail = ""
    var sellerId = ""
    var orderID = ""

    init(status:String, trackingNum:String, curriorCompany:String, weight:String, price:String,sellerEmail:String, sellerId:String, orderID:String) {
        self.status = status
        self.trackingNum = trackingNum
        self.curriorCompany = curriorCompany
        self.weight = weight
        self.price = price
        self.sellerEmail = sellerEmail
        self.sellerId = sellerId
        self.orderID = orderID
    }
    
    init(status:String, trackingNum:String, curriorCompany:String, weight:String, price:String, sellerId:String, orderID:String) {
        self.status = status
        self.trackingNum = trackingNum
        self.curriorCompany = curriorCompany
        self.weight = weight
        self.price = price
        self.sellerId = sellerId
        self.orderID = orderID
    }
}
