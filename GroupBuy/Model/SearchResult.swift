//
//  SearchResult.swift
//  StoreSearch
//
//  Created by KaiJun Tong on 09/09/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import Foundation

class SearchResult{
    var itemName:String = ""
    var itemKey:String = ""
    
    var itemImageURL:String = ""
    var itemPrice:Double = 0.0
}

func <(lhs: SearchResult, rhs: SearchResult) -> Bool{
    return lhs.itemName.localizedStandardCompare(rhs.itemName) == .orderedAscending
}
