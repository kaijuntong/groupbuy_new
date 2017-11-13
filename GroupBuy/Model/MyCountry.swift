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
    var countryImage:String = ""
    var startDate:Double = 0.0
    var dueDate:Double = 0.0
    var countryName:String = ""
    var eventKey:String = ""
    
    init(eventKey:String,countryName:String, startDate:Double, dueDate:Double, countryImage:String) {
        self.eventKey = eventKey
        self.countryName = countryName
        self.startDate = startDate
        self.dueDate = dueDate
        self.countryImage = countryImage
        
    }
}
