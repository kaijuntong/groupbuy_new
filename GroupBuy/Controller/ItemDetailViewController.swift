//
//  ItemDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 10/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class ItemDetailViewController: UITableViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var item :CountryItems!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let productImage = item.productImage{
            productImageView.image = productImage
        }
        
        productLabel.text = item.itemName
        priceLabel.text = "\(item.itemPrice)"
        sizeLabel.text = "250 ml"
    }
}
