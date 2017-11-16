//
//  MyOrderDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 13/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class MyOrderDetailViewController: UITableViewController {
    
    var orderKey:String!
    var ref:DatabaseReference!
    var userID:String? =  Auth.auth().currentUser?.uid
    
    var addresss:String = ""
    var orderDate:Double = 0.0
    var paymentAmount:Double = 0.0
    var orderItemArray:[Cart] = [Cart]()
    var doneLoading = false
    
    override func viewDidLoad() {
        self.doneLoading = false

        super.viewDidLoad()
        ref = Database.database().reference()
        configureDatabase()
        var cellNib:UINib = UINib(nibName: "TitleCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "TitleCell")
        
        cellNib = UINib(nibName: "AddressCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "AddressCell")
        
        cellNib = UINib(nibName: "SummaryCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SummaryCell")
        
        cellNib = UINib(nibName: "OrderItemCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "OrderItemCell")
        
      //  tableView.estimatedRowHeight  = 44
        //tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orderItemArray.count + 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            let orderKeyLabel = cell.viewWithTag(100) as! UILabel
            let paymentAmountLabel = cell.viewWithTag(101) as! UILabel
            let dateLabel = cell.viewWithTag(102) as! UILabel
            
            orderKeyLabel.text = orderKey
            paymentAmountLabel.text = "\(paymentAmount)"
            dateLabel.text = displayTimestamp(ts: orderDate)
            
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.text = addresss
            return cell
        }else{
            var currentRow = indexPath.row
            if !doneLoading{
                return tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath)
            }
            
            currentRow = indexPath.row - 2
            let cell =  tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderItemViewCell
            
            let itemNameLabel = cell.viewWithTag(100) as! UILabel
            let quantityLabel = cell.viewWithTag(101) as! UILabel
            let totalPriceLabel = cell.viewWithTag(102) as! UILabel
            let imageView = cell.viewWithTag(103) as! UIImageView
            
            itemNameLabel.text = orderItemArray[currentRow].itemName.capitalized
            quantityLabel.text = "\(orderItemArray[currentRow].itemQuantity)"
            
            let totalPrice = orderItemArray[currentRow].itemPrice * Double(orderItemArray[currentRow].itemQuantity)
            totalPriceLabel.text = "RM \(totalPrice)"
            
            //load image
            let imageURL:String = orderItemArray[currentRow].itemImage
            if imageURL.hasPrefix("gs://") {
                Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        imageView.image = UIImage.init(data: data!)
                    }
                }
            }
            return cell
            
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showItemDetail", sender: cell)

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func configureDatabase(){
        ref.child("orderlist").child("\(orderKey!)").observeSingleEvent(of:.value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            

            self.addresss = a["deliveryAddress"] as! String
            self.orderDate = a["order_date"] as! Double
            self.paymentAmount = a["paymentPrice"] as! Double
            
            let orderItems = a["orderItems"] as! [String:AnyObject]
            
            for (itemKey,value) in orderItems{
                    let itemName = value["itemName"] as! String
                    let itemPrice = value["itemPrice"] as! Double
                    let itemQuantity = value["itemQuantity"] as! Int
                    let itemImage = value["itemImage"] as! String
                    let eventKey = value["eventKey"] as! String
                
                    let cartItem:Cart = Cart.init(eventKey: eventKey,itemKey:itemKey, itemName: itemName, itemPrice: itemPrice, itemImage: itemImage, itemQuantity: itemQuantity)
                    self.orderItemArray.append(cartItem)
            }
            self.orderItemArray.sort{$0 < $1}
            self.doneLoading = true
            self.tableView.reloadData()
//
//            if let value1 = a as? [String:NSDictionary]{
//                for (itemID,value) in value1{
//
//                    let valueDict:[String:AnyObject] = value as! [String:AnyObject]
//                    //let itemDict = valueDict as! [String:AnyObject]
//
//                    let quantityDict:[String:Int] = valueDict["buyer_info"] as! [String:Int]
//                    let status:Int = valueDict["status"] as? Int ?? 0
//                    let checked:Bool = (status == 1 ? true:false)
//
//                    var quantity:Int = 0
//
//                    for (key,value) in quantityDict{
//                        let v:Int = value
//                        quantity += v
//                    }
//
//                    self.ref.child("eventItems").child("\(itemID)").observeSingleEvent(of: .value, with: {
//                        (snapshot) in
//                        let value2:NSDictionary? = snapshot.value as? NSDictionary
//                        if let value3 = value2 as? [String:AnyObject]{
//                            let itemName:String = value3["itemName"] as! String
//
//                            let purchasingItem:PurchasingChecklistItem = PurchasingChecklistItem.init(eventID:self.eventID!, itemID:itemID, itemName: itemName, quantity: quantity,checked: checked)
//                            self.purchasingListArray.append(purchasingItem)
//                        }
//                        self.tableView.reloadData()
//                    })
//                }
//                self.tableView.reloadData()
//            }
        }){
            (error) in
            print(error.localizedDescription)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetail"{
            let destination:ItemDetailViewController = segue.destination as! ItemDetailViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                destination.passByItemID = true
                print(indexPath.row)
                destination.itemKey = orderItemArray[indexPath.row - 2].itemKey
                
            }
        }
    }

    
}
