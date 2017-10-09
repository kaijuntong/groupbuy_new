//
//  CountryItems.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class CountryItems{
    var username = ""
    var itemName = ""
    var itemPrice = -1.0
    var itemSalesQuantity = -1
    var productImage: UIImage?
    
    init(username:String, itemName:String, itemPrice:Double, itemSaleQuantity:Int,productImage:UIImage!) {
        self.username = username
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemSalesQuantity = itemSaleQuantity
        self.productImage = productImage
    }
}
