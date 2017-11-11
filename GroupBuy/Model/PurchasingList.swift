//
//  PurchasingList.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 09/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class PurchasingList{
    var startDate = 0.0
    var endDate = 0.0
    var countryName = ""
    var eventKey = ""
    
    init(eventKey:String, countryName:String, startDate:Double, endDate:Double) {
       self.eventKey = eventKey
        self.countryName = countryName
        self.startDate = startDate
        self.endDate = endDate
    }
}
