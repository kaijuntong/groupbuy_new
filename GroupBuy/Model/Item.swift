//
//  Item.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 20/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation
import UIKit
class Item{
    var itemKey:String = ""
    var itemName:String = ""
    var description:String = ""
    var price:Double = 0.0
    var size:String = ""
    var imageLoc:String = ""
    
    init(itemKey:String, itemName:String, itemDescription:String, itemPrice:Double, itemSize:String, imageLoc:String) {
        self.itemKey = itemKey
        self.itemName = itemName
        self.description = itemDescription
        self.price = itemPrice
        self.size = itemSize
        self.imageLoc = imageLoc
    }
}
