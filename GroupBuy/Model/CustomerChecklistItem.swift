//
//  CustomerChecklistItem.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 12/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation
import Firebase

class CustomerChecklistItem{
    
    var ref = Database.database().reference()
    var userID =  Auth.auth().currentUser?.uid
    
    var userId = ""
    var checked = false
    var itemID = ""
    var buyerItemArray = [CustomerBuyItem]()
    
    init(userId:String, buyerItemArray:[CustomerBuyItem], checked:Bool) {
        self.userId = userId
        
        self.buyerItemArray = buyerItemArray
        self.checked = checked
    }
    
    func toogleChecked(){
        checked = !checked
        
        let num = checked ? 1 : 0
        
        //ref.child("customer_list").child("\(eventID)").child("\(itemID)/status").setValue(num)
    }
    
    
}
