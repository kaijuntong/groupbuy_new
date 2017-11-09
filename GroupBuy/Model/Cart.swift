//
//  Cart.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 04/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class Cart{
    var itemName = ""
    var itemPrice = 0.0
    var itemImage = ""
    var itemQuantity = 0
    var itemKey = ""
    var eventKey = ""
    
    init(eventKey:String, itemKey:String,itemName:String, itemPrice:Double, itemImage:String, itemQuantity:Int) {
        self.eventKey = eventKey
        self.itemKey = itemKey
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemImage = itemImage
        self.itemQuantity = itemQuantity
    }
}
