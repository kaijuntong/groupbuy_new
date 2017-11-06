//
//  cartFooterViewCell.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class cartFooterViewCell: UITableViewCell {

    @IBOutlet weak var estimatedPriceLabel: UILabel!
    @IBOutlet weak var processBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
