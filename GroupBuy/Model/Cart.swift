//
//  Cart.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 04/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class Cart{
    var itemName:String = ""
    var itemPrice:Double = 0.0
    var itemImage:String = ""
    var itemQuantity:Int = 0
    var itemKey:String = ""
    var eventKey:String = ""
    
    init(eventKey:String, itemKey:String,itemName:String, itemPrice:Double, itemImage:String, itemQuantity:Int) {
        self.eventKey = eventKey
        self.itemKey = itemKey
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemImage = itemImage
        self.itemQuantity = itemQuantity
    }
}

func <(lhs: Cart, rhs: Cart) -> Bool{
    return lhs.itemName.localizedStandardCompare(rhs.itemName) == .orderedAscending
}
