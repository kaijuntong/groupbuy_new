//
//  MyCountry.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 21/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation
import UIKit

class MyCountry{
    var countryImage = ""
    var startDate = 0.0
    var dueDate = 0.0
    var countryName = ""
    var eventKey = ""
    
    init(eventKey:String,countryName:String, startDate:Double, dueDate:Double, countryImage:String) {
        self.eventKey = eventKey
        self.countryName = countryName
        self.startDate = startDate
        self.dueDate = dueDate
        self.countryImage = countryImage
        
    }
}
