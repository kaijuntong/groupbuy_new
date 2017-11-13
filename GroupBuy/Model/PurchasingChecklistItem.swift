//
//  PurchasingChecklistItem.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 09/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation
import Firebase

class PurchasingChecklistItem{
    
    var ref:DatabaseReference = Database.database().reference()
    var userID:String? =  Auth.auth().currentUser?.uid
    
    var eventID:String = ""
    var itemName:String = ""
    var quantity:Int = 0
    var checked:Bool = false
    var itemID:String = ""
    
    init(eventID:String,itemID:String, itemName:String, quantity:Int, checked:Bool) {
        self.eventID = eventID
        self.itemID = itemID
        self.itemName = itemName
        self.quantity = quantity
        self.checked = checked
    }

    func toogleChecked(){
        checked = !checked
        
        let num:Int = checked ? 1 : 0
        
        ref.child("purchasing_list").child("\(eventID)").child("\(itemID)/status").setValue(num)
    }

 
}
