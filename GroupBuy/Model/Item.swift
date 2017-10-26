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
    var itemKey = ""
    var itemName = ""
    var description = ""
    var price = 0.0
    var size = ""
    var imageLoc = ""
    
    init(itemKey:String, itemName:String, itemDescription:String, itemPrice:Double, itemSize:String, imageLoc:String) {
        self.itemKey = itemKey
        self.itemName = itemName
        self.description = itemDescription
        self.price = itemPrice
        self.size = itemSize
        self.imageLoc = imageLoc
    }
}
