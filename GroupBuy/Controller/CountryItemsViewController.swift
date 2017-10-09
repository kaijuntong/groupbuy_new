//
//  CountryItemsViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class CountryItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet var collectionView:UICollectionView!
    
    private var countryItems:[CountryItems] = [CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //configure cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as!
            ContryItemsCollectionViewCell
        
        // Configure the cell
        cell.productNameLabel.text = countryItems[indexPath.row].itemName
        cell.usernameLabel.text = countryItems[indexPath.row].username
        cell.quantityLabel.text = "\(countryItems[indexPath.row].itemSalesQuantity)"
        cell.priceLabel.text = "\(countryItems[indexPath.row].itemPrice)"
        
        cell.productImage.image = countryItems[indexPath.row].productImage
        //apply round corner
        cell.layer.cornerRadius = 4.0
        
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetail"{
            if let indexPath = collectionView.indexPathsForSelectedItems{
                let destinationController = segue.destination as! ItemDetailViewController
                destinationController.item = countryItems[indexPath.last!.row]
            }
        }
    }
}
