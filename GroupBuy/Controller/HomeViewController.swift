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
   // @IBOutlet var sellerCollectionView:UICollectionView!
    
    private var countries:[Country] = [Country.init(countryName: "USA", countryImage: UIImage(named: "usa")),
                                       Country.init(countryName: "Taiwan", countryImage: UIImage(named: "taiwan")),
                                       Country.init(countryName: "Korea", countryImage: UIImage(named: "korea")),
                                       Country.init(countryName: "Australia", countryImage: UIImage(named: "australia")),
                                       ]
    
    fileprivate var _refHandle: DatabaseHandle!
    var ref:DatabaseReference!
    
    private var countryItems:[CountryItems] =  [CountryItems]()

    
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
            let cell:CountryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountriesCell", for: indexPath) as! CountryCollectionViewCell
            
            // Configure the cell
            cell.countryName.text = countries[indexPath.row].countryName
            cell.countryImage.image = countries[indexPath.row].countryImage
            
            //apply round corner
            cell.layer.cornerRadius = 4.0
            return cell
        }
        else if collectionView == self.hottestItemsCollectionView{
            let cell:HottestItemViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCell", for: indexPath) as! HottestItemViewCell
            
            //load image
            let imageURL:String = countryItems[indexPath.row].productImage
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
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SellerCell", for: indexPath)
            let imageview:UIImageView = cell.viewWithTag(20) as! UIImageView
            imageview.layer.cornerRadius = 40
            imageview.clipsToBounds = true
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountryItems"{
            let controller:CountryItemsViewController = segue.destination as! CountryItemsViewController
            
            if let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell){
                let countryName:String = countries[indexPath.row].countryName
                
                controller.countryName = countryName
            }
        }else if segue.identifier == "showItemDetail"{
            if let indexPath = hottestItemsCollectionView.indexPathsForSelectedItems{
                let destinationController:ItemDetailViewController = segue.destination as! ItemDetailViewController
                destinationController.item = countryItems[indexPath.last!.row]
            }
        }
    }
    
    func configureDatabase(){
        ref = Database.database().reference()
        let user:User? = Auth.auth().currentUser
        if let user = user {
            let uid:String = user.uid
            
            //listen for new messages in the firebase database
            _refHandle = ref.child("eventItems").queryLimited(toFirst: 10).observe(.value){
                (snapshot:DataSnapshot) in
                
                
                //remove previous data
                //self.eventItems.removeAll()
                self.countryItems.removeAll()
                let a = snapshot.value as? [String:AnyObject] ?? [:]
                
                print("-------a")
                print(a)
                print("-------a")
                
                for (key,value) in a{
                    let abc:[String:AnyObject] = value as![String:AnyObject]
                    
                    let itemName:String = abc["itemName"] as! String
                    let itemSize:String = abc["itemSize"] as! String
                    let itemDescription:String = abc["itemDescription"] as! String
                    let itemPrice:Double = abc["itemPrice"] as! Double
                    let itemImage:String = abc["itemImage"] as! String
                    let sellerID:String = abc["uid"] as! String
                    
                    let eventIdInfo = abc["event_id1"] as! [String:AnyObject]
                    
                    let startDate:Double = eventIdInfo["departdate"] as! Double
                    let dueDate:Double = eventIdInfo["returndate"] as! Double

                    
                    //create item object
                    let countryItem:CountryItems = CountryItems(itemKey: key, username: "", itemName: itemName, itemPrice: itemPrice, itemSaleQuantity: 0, productImage: itemImage, sellerID: sellerID, itemDescription:itemDescription, itemSize:itemSize,startDate:startDate,dueDate:dueDate)
                    
                    self.countryItems.append(countryItem)
                }
                
                self.hottestItemsCollectionView.reloadData()
            }
        }
        
    }

}

