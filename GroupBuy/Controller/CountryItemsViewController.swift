//
//  CountryItemsViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class CountryItemsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet var collectionView:UICollectionView!
    fileprivate var _refHandle: DatabaseHandle!
     var ref:DatabaseReference!
    
    private var countryItems =  [CountryItems]()
    
    
        //= [CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa")),CountryItems.init(username: "KaiJun", itemName: "鸡蛋仔", itemPrice: 123.0, itemSaleQuantity: 9,productImage:UIImage(named: "usa"))]
    
    var countryName:String!
    
    override func viewDidLoad() {
        self.title = countryName
        super.viewDidLoad()
        print(countryName)
        configureDatabase()
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
        
        //cell.productImage.image = countryItems[indexPath.row].productImage
        
        //load image
        let imageURL = countryItems[indexPath.row].productImage
        if imageURL.hasPrefix("gs://") {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    cell.productImage.image = UIImage.init(data: data!)
                    //itemImageView.image = UIImage.init(data: data!)
                }
            }
        }
        
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
    
    func configureDatabase(){
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            
            //listen for new messages in the firebase database
            _refHandle = ref.child("eventItems").queryOrdered(byChild: "event_id1/destination").queryEqual(toValue: countryName.lowercased()).observe(.value){
                (snapshot:DataSnapshot) in
                print(snapshot)
                
                //remove previous data
                //self.eventItems.removeAll()
                let a = snapshot.value as? [String:AnyObject] ?? [:]
                print(a)
                //

                for (key,value) in a{
                    let abc = value as![String:AnyObject]

                    let itemName = abc["itemName"] as! String
                    let itemSize = abc["itemSize"] as! String
                    let itemDescription = abc["itemDescription"] as! String
                    let itemPrice = abc["itemPrice"] as! Double
                    let itemImage = abc["itemImage"] as! String
                    let sellerID = abc["uid"] as! String
                    
                    //create item object
                    
                    let countryItem = CountryItems(itemKey: key, username: "", itemName: itemName, itemPrice: itemPrice, itemSaleQuantity: 0, productImage: itemImage, sellerID: sellerID)
                    
                    self.countryItems.append(countryItem)
                }
                
                self.collectionView.reloadData()
            }
        }
        
    }
}
