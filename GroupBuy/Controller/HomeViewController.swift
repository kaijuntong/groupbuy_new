//
//  HomeViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 05/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView:UICollectionView!
    @IBOutlet var hottestItemsCollectionView:UICollectionView!
    @IBOutlet var sellerCollectionView:UICollectionView!
    
    private var countries:[Country] = [Country.init(countryName: "USA", countryImage: UIImage(named: "usa")),
                                       Country.init(countryName: "Taiwan", countryImage: UIImage(named: "taiwan")),
                                       Country.init(countryName: "Korea", countryImage: UIImage(named: "korea")),
                                       Country.init(countryName: "Australia", countryImage: UIImage(named: "australia")),
                                       ]
    
    fileprivate var _refHandle: DatabaseHandle!
    var ref:DatabaseReference!
    
    private var countryItems =  [CountryItems]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            return countries.count
        }else if collectionView == self.hottestItemsCollectionView{
            print(countryItems.count)
            return countryItems.count
        }else{
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountriesCell", for: indexPath) as! CountryCollectionViewCell
            
            // Configure the cell
            cell.countryName.text = countries[indexPath.row].countryName
            cell.countryImage.image = countries[indexPath.row].countryImage
            
            //apply round corner
            cell.layer.cornerRadius = 4.0
            return cell
        }
        else if collectionView == self.hottestItemsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCell", for: indexPath) as! HottestItemViewCell
            
            //load image
            let imageURL = countryItems[indexPath.row].productImage
            if imageURL.hasPrefix("gs://") {
                Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage.init(data: data!)
                        //itemImageView.image = UIImage.init(data: data!)
                    }
                }
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SellerCell", for: indexPath)
            let imageview = cell.viewWithTag(20) as! UIImageView
            imageview.layer.cornerRadius = 40
            imageview.clipsToBounds = true
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountryItems"{
            let controller = segue.destination as! CountryItemsViewController
            
            if let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell){
                let countryName = countries[indexPath.row].countryName
                
                controller.countryName = countryName
            }
        }else if segue.identifier == "showItemDetail"{
            if let indexPath = hottestItemsCollectionView.indexPathsForSelectedItems{
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
            _refHandle = ref.child("eventItems").queryLimited(toFirst: 10).observe(.value){
                (snapshot:DataSnapshot) in
                
                
                //remove previous data
                //self.eventItems.removeAll()
                self.countryItems.removeAll()
                let a = snapshot.value as? [String:AnyObject] ?? [:]
                
                
                
                for (key,value) in a{
                    let abc = value as![String:AnyObject]
                    
                    let itemName = abc["itemName"] as! String
                    let itemSize = abc["itemSize"] as! String
                    let itemDescription = abc["itemDescription"] as! String
                    let itemPrice = abc["itemPrice"] as! Double
                    let itemImage = abc["itemImage"] as! String
                    let sellerID = abc["uid"] as! String
                    
                    //create item object
                    
                    let countryItem = CountryItems(itemKey:key, username: "", itemName: itemName, itemPrice: itemPrice, itemSaleQuantity: 0, productImage: itemImage, sellerID: sellerID, itemDescription:itemDescription, itemSize:itemSize)
                    
                    self.countryItems.append(countryItem)
                }
                
                self.hottestItemsCollectionView.reloadData()
            }
        }
        
    }

}

