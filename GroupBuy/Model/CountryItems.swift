//
//  CountryItems.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class CountryItems{
    var username:String = ""
    var itemKey:String = ""
    var itemName:String = ""
    var itemPrice:Double = -1.0
    var itemSalesQuantity:Int = -1
    var itemDescription:String = ""
    var itemSize:String = ""
    var productImage:String = ""
    var sellerID:String = ""
    var startDate:Double = 0.0
    var dueDate:Double = 0.0
    
    init(itemKey:String,username:String, itemName:String, itemPrice:Double, itemSaleQuantity:Int,productImage:String, sellerID:String, itemDescription:String, itemSize:String) {
        self.itemKey = itemKey
        self.username = username
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemSalesQuantity = itemSaleQuantity
        self.productImage = productImage
        self.sellerID = sellerID
        self.itemDescription = itemDescription
        self.itemSize = itemSize
    }
    
    init(itemKey:String,username:String, itemName:String, itemPrice:Double, itemSaleQuantity:Int,productImage:String, sellerID:String, itemDescription:String, itemSize:String,startDate:Double,dueDate:Double) {
        self.itemKey = itemKey
        self.username = username
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemSalesQuantity = itemSaleQuantity
        self.productImage = productImage
        self.sellerID = sellerID
        self.itemDescription = itemDescription
        self.itemSize = itemSize
        self.startDate = startDate
        self.dueDate = dueDate
    }
}

func <(lhs: CountryItems, rhs: CountryItems) -> Bool{
    return lhs.itemName.localizedStandardCompare(rhs.itemName) == .orderedAscending
}
