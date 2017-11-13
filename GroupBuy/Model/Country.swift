//
//  Country.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

struct Country{
    var countryName:String = ""
    var countryImage: UIImage?
    
    init(countryName:String, countryImage:UIImage!) {
        self.countryName = countryName
        self.countryImage = countryImage
    }
}
