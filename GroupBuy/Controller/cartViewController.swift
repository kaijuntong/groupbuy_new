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
    
    var cartArray:[Cart] = [Cart]()
    var ref:DatabaseReference!
    var userID:String?
    var localEstimatedTotal:Double = 0.0
    
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
        let cell:MyCartViewCell = tableView.dequeueReusableCell(withIdentifier:"Cell" , for: indexPath) as! MyCartViewCell
        
        cell.itemName.text = "\(cartArray[indexPath.row].itemName.capitalized)"
        cell.itemPrice.text = "RM \(cartArray[indexPath.row].itemPrice)"
        cell.quantityLabel.text = "\(cartArray[indexPath.row].itemQuantity)"
        
        cell.selfObject = cartArray[indexPath.row]
        cell.setStepperValue(num: cartArray[indexPath.row].itemQuantity)
        cell.myrow = indexPath.row
        cell.delegate = self
        
        //load image
        let imageURL:String = cartArray[indexPath.row].itemImage
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
                    let valueDict:[String:AnyObject] = value as! [String:AnyObject]
                    //let itemDict = valueDict as! [String:AnyObject]
                    
                    let quantity:Int = valueDict["quantity"] as! Int
                        
                        //self.ref.child("eventItems").child("\(key)").observe(.value, with: {
                        self.ref.child("eventItems").child("\(key)").observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            let value2:NSDictionary? = snapshot.value as? NSDictionary
                            if let value3 = value2 as? [String:AnyObject]{
                                //print(value3)
                                let eventKey:String = value3["event_id"] as! String
                                let itemName:String = value3["itemName"] as! String
                                let itemPrice:Double = value3["itemPrice"] as! Double
                                let itemImage:String = value3["itemImage"] as! String
                                
                                let cartItem:Cart = Cart.init(eventKey: eventKey,itemKey:key, itemName: itemName, itemPrice: itemPrice, itemImage: itemImage, itemQuantity: quantity)
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell:cartFooterViewCell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") as! cartFooterViewCell
        cell.estimatedPriceLabel.text = "RM \(calculatedEstimatedPrice())"
       
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = CGSize(width: 375, height: 3)
        
        let stopColor:CGColor = UIColor.white.cgColor
        let startColor:CGColor = UIColor.lightGray.cgColor
        
        gradient.colors = [stopColor, startColor]
        gradient.locations = [0.0,0.8]
        
        cell.layer.addSublayer(gradient)
        print("--------")
        print(section)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 106
    }
    
    func removeRow(row:Int){
        cartArray.remove(at: row)
        tableView.reloadData()
    }
    
    func updateFooterView(quantity:Double, row:Int){
        cartArray[row].itemQuantity = Int(quantity)
        tableView.reloadData()
    }
    
    func calculatedEstimatedPrice() -> Double{
        var estimatedTotal:Double = 0.0

        for item in cartArray{
            estimatedTotal += Double(item.itemQuantity) * item.itemPrice
        }
        
        localEstimatedTotal = estimatedTotal
        return estimatedTotal
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPaymentTable"{
            let controller:PaymentTableViewController = segue.destination as! PaymentTableViewController
            controller.cartArray = cartArray
            controller.totalPrice = localEstimatedTotal
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
