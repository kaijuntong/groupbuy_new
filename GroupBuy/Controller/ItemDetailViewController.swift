//
//  ItemDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 10/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ItemDetailViewController: UITableViewController {
    var ref:DatabaseReference!
    var user:User?
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sellerEmail: UILabel!
    @IBOutlet weak var sellerProfilePic: UIImageView!
    
    var item :CountryItems?

    var passByItemID = false
    var itemKey = ""
    var sellerID1 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser

        ref = Database.database().reference()
        if passByItemID{
            ref.child("eventItems/\(itemKey)").observeSingleEvent(of: .value, with: {(snapshot) in
                print(snapshot)
                let value = snapshot.value as? [String:AnyObject]
                if let value = value{
                    let itemName:String = value["itemName"] as! String
                    let itemSize:String = value["itemSize"] as! String
                    let itemDescription:String = value["itemDescription"] as! String
                    let itemPrice:Double = value["itemPrice"] as! Double
                    let itemImage:String = value["itemImage"] as! String
                    let sellerID:String = value["uid"] as! String
                    self.sellerID1 = sellerID
                    
                    let eventIdInfo = value["event_id1"] as! [String:AnyObject]
                    
                    let startDate:Double = eventIdInfo["departdate"] as! Double
                    let dueDate:Double = eventIdInfo["returndate"] as! Double
                    
                    let countryItem:CountryItems = CountryItems(itemKey: self.itemKey, username: "", itemName: itemName, itemPrice: itemPrice, itemSaleQuantity: 0, productImage: itemImage, sellerID: sellerID, itemDescription:itemDescription, itemSize:itemSize,startDate:startDate,dueDate:dueDate)
                    
                    self.item = countryItem
                    self.loadData()
                    self.tableView.reloadData()
                }
            })
        }
        
        loadData()
        
    }
    
    func loadData(){
        if let item = item{
            if item.productImage.hasPrefix("gs://") {
                Storage.storage().reference(forURL: item.productImage).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.productImageView.image = UIImage.init(data: data!)
                    }
                }
            }
            
            let dateString = "\(displayTimestamp(ts:item.startDate)) - \(displayTimestamp(ts:item.dueDate))"
            timeLabel.text = dateString.capitalized
            productLabel.text = item.itemName.capitalized
            priceLabel.text = "\(item.itemPrice)"
            sizeLabel.text = "\(item.itemSize)".capitalized
            descriptionLabel.text = "\(item.itemDescription)".capitalized
            
            
            ref.child("users").child(item.sellerID).observeSingleEvent(of: .value, with: {(snapshot) in
                //get user value
                let value:NSDictionary? = snapshot.value as? NSDictionary
                print(value)
                let email:String = value?["email"] as? String ?? ""
                
                let profilePic = value?["profilePicture"] as? String ?? ""
                if profilePic.hasPrefix("gs://") {
                    Storage.storage().reference(forURL: profilePic).getData(maxSize: INT64_MAX) {(data, error) in
                        if let error = error {
                            print("Error downloading: \(error)")
                            return
                        }
                        DispatchQueue.main.async {
                            self.sellerProfilePic.image = UIImage.init(data: data!)
                        }
                    }
                }
                
                self.sellerEmail.text = email.lowercased()
            }){
                (error) in
                print(error.localizedDescription)
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0{
            addToCart()
            
            let alertController:UIAlertController = UIAlertController(title: "Done", message: "Succescul added to cart", preferredStyle: .alert)
            let okAction:UIAlertAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = item, let user = user{
            if item.sellerID == user.uid{
                 if indexPath.section == 2 && indexPath.row == 0{
                    return 0
                 }else{
                    return super.tableView(tableView, heightForRowAt: indexPath)
                    
                }
            }else{
                 return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func addToCart(){
        if let item = item{
        if let user = user {
            let uid:String = user.uid
            var cartItem:[String:Any] = [String:Any]()

            //cartItem["item_id"] = item.itemKey
            cartItem["quantity"] = 1
//
            //ref.child("cart_item").child(uid).childByAutoId().setValue(cartItem)
            ref.child("cart_item").child(uid).child("\(item.itemKey)").setValue(cartItem)
        }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let item = item{
        if segue.identifier == "showUserDetail"{
            print(item.sellerID)
            print(item.sellerID)
            print(item.sellerID)

            let controller:SellerDetailViewController = segue.destination as! SellerDetailViewController
            controller.sellerID = item.sellerID
            print(item.sellerID)
        }
        }
    }
    
    func displayTimestamp(ts: Double) -> String {
        let date:Date = Date(timeIntervalSince1970: ts)
        let formatter:DateFormatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
    
}
