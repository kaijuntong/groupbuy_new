//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by KaiJun Tong on 09/09/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView:UIView = UIView(frame:.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(for searchResult:CountryItems){
        nameLabel.text = searchResult.itemName
        artistNameLabel.text = "\(searchResult.itemPrice)"
        
        artworkImageView.image = UIImage(named: "Placeholder")

        if searchResult.productImage.hasPrefix("gs://") {
            Storage.storage().reference(forURL: searchResult.productImage).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    
                    self.artworkImageView.image = UIImage.init(data: data!)
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
