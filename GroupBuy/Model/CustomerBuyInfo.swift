//
//  CustomerBuyInfo.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation
import Firebase

class CustomerBuyInfo{
    var ref:DatabaseReference = Database.database().reference()
    
    
    var address = ""
    var email = ""
    var itemInfo = [CustomerBuyItem]()
    var eventID = ""
    var orderID = ""
    var userID = ""
    var checked = false
    
    init(address:String, itemInfo:[CustomerBuyItem],email:String, checked:Bool) {
        self.address = address
        self.itemInfo = itemInfo
        self.email = email
    }

    init(eventID:String,orderID:String, userID:String, address:String, itemInfo:[CustomerBuyItem],email:String, checked:Bool) {
        self.eventID = eventID
        self.orderID = orderID
        self.userID = userID
        self.address = address
        self.itemInfo = itemInfo
        self.email = email
        self.checked = checked
    }

    func toogleChecked(){
        checked = !checked
        
        let num:Int = checked ? 1 : 0
    
        ref.child("customerlist/\(eventID)/\(orderID)/\(userID)/status").setValue(num)
    }
}

func <(lhs: CustomerBuyInfo, rhs: CustomerBuyInfo) -> Bool{
    return lhs.email.localizedStandardCompare(rhs.email) == .orderedAscending
}
