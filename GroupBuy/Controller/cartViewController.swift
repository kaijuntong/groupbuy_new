//
//  cartViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 26/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class cartViewController: UITableViewController, MyCartViewCellDelegate{
    
    var cartArray = [Cart]()
    var ref:DatabaseReference!
    var userID:String?
    
    
    fileprivate var _refHandle1: DatabaseHandle!
    fileprivate var _refHandle2: DatabaseHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //configureDatabase()
        userID =  Auth.auth().currentUser?.uid
        //configureDatabase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureDatabase()
        cartArray.removeAll()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cartArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell" , for: indexPath) as! MyCartViewCell
        
        cell.itemName.text = "\(cartArray[indexPath.row].itemName)"
        cell.itemPrice.text = "\(cartArray[indexPath.row].itemPrice)"
        cell.quantityLabel.text = "\(cartArray[indexPath.row].itemQuantity)"
        
        cell.selfObject = cartArray[indexPath.row]
        cell.setStepperValue(num: cartArray[indexPath.row].itemQuantity)
        cell.delegate = self
        //load image
        let imageURL = cartArray[indexPath.row].itemImage
        if imageURL.hasPrefix("gs://") {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    cell.itemImageView.image = UIImage.init(data: data!)
                    //itemImageView.image = UIImage.init(data: data!)
                }
            }
        }

        
        return cell
    }
    
    func configureDatabase(){
        //ref.child("user_rating").child(self.sellerID!).observeSingleEvent(of: .value, with: {(snapshot) in
        print("this is user id \(userID!)")
        
        //_refHandle = ref.queryOrdered(byChild: "cart_item").queryEqual(toValue: "\(userID!)").observe(.value, with: {(snapshot) in
        ref.child("cart_item").child("\(userID!)").observeSingleEvent(of:.value, with: {(snapshot) in
        //_refHandle1 = ref.child("cart_item").queryOrderedByKey().queryEqual(toValue: "\(userID!)").observe(.value, with: {(snapshot) in
            //get user value
            
            self.cartArray.removeAll()
            
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            
            if let value1 = a as? [String:NSDictionary]{
                for (key,value) in value1{
                    //print(key)
                    let valueDict = value as! [String:AnyObject]
                    //let itemDict = valueDict as! [String:AnyObject]
                    
                    
                    
                        let quantity = valueDict["quantity"] as! Int
                        
                        //self.ref.child("eventItems").child("\(key)").observe(.value, with: {
                        self.ref.child("eventItems").child("\(key)").observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            let value2 = snapshot.value as? NSDictionary
                            if let value3 = value2 as? [String:AnyObject]{
                                //print(value3)
                                
                                let itemName = value3["itemName"] as! String
                                let itemPrice = value3["itemPrice"] as! Double
                                let itemImage = value3["itemImage"] as! String
                                
                                let cartItem = Cart.init(itemKey:key, itemName: itemName, itemPrice: itemPrice, itemImage: itemImage, itemQuantity: quantity)
                                self.cartArray.append(cartItem)
                            }
                            self.tableView.reloadData()
                        })
                    
                    
                }
                self.tableView.reloadData()
            }
            
            //observe
//            if let value1 = a as? [String:NSDictionary]{
//                for (key,value) in value1{
//                    //print(key)
//                    let valueDict = value as! [String:AnyObject]
//                    let itemDict = valueDict as! [String:AnyObject]
//
//                    for (key,cartItemValue) in itemDict{
//                        let quantity = cartItemValue["quantity"] as! Int
//
//                        //self.ref.child("eventItems").child("\(key)").observe(.value, with: {
//                        self.ref.child("eventItems").child("\(key)").observeSingleEvent(of: .value, with: {
//                            (snapshot) in
//                            let value2 = snapshot.value as? NSDictionary
//                            if let value3 = value2 as? [String:AnyObject]{
//                                //print(value3)
//
//                                let itemName = value3["itemName"] as! String
//                                let itemPrice = value3["itemPrice"] as! Double
//                                let itemImage = value3["itemImage"] as! String
//
//                                let cartItem = Cart.init(itemKey:key, itemName: itemName, itemPrice: itemPrice, itemImage: itemImage, itemQuantity: quantity)
//                                self.cartArray.append(cartItem)
//                            }
//                            self.tableView.reloadData()
//                        })
//                    }
//
//                }
//                self.tableView.reloadData()
//            }
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateTableView() {
        print("Done")
        self.configureDatabase()
    }
}
