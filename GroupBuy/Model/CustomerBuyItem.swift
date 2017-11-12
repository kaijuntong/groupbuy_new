//
//  CustomerBuyItem.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 12/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class CustomerBuyItem{
    var itemKey = ""
    var itemQuantity = 0
    var itemName = ""
    
    init(itemKey:String, itemQuantity:Int, itemName:String) {
        self.itemKey = itemKey
        self.itemQuantity = itemQuantity
        self.itemName = itemName
    }
    
    init(itemKey:String, itemQuantity:Int) {
        self.itemKey = itemKey
        self.itemQuantity = itemQuantity
    }
}
