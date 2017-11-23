//
//  secondPaymentViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 23/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class secondPaymentViewController: UITableViewController {
    var selectedCustomerBuyInfo:CustomerBuyInfo!
    var ref:DatabaseReference!
    var userID:String? =  Auth.auth().currentUser?.uid
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var itemInfoLabel: UILabel!
    
    @IBOutlet weak var curriorTextField: UITextField!
    @IBOutlet weak var TrackingNumLabel: UITextField!
    @IBOutlet weak var weightLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        addressLabel.text = selectedCustomerBuyInfo.address
        var itemString:String = ""
        
        let customerBuyItemArray:[CustomerBuyItem] = selectedCustomerBuyInfo.itemInfo
        
        for i in customerBuyItemArray{
            itemString += i.itemName
            itemString += "\tx\(i.itemQuantity)\n"
            itemInfoLabel.text = itemString
        }
        
        
        ref.child("secondPayment/\(userID!)/\(selectedCustomerBuyInfo.orderID)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let a = snapshot.value as? [String:String] ?? [:]
            print(a)
            
            
            self.curriorTextField.text = a["curriorCompany"]
            self.TrackingNumLabel.text = a["trackingNum"]
            self.weightLabel.text = a["weight"]
            self.priceLabel.text = a["price"]
            
            let status = a["paidStatus"]
            
            if let status = status{
                if status == "2"{
                    self.curriorTextField.isEnabled = false
                    self.TrackingNumLabel.isEnabled = false
                    self.weightLabel.isEnabled = false
                    self.priceLabel.isEnabled = false
                    self.saveBtn.isEnabled = false
                    
                }
            }
//            if let value1 = a as? [String:NSDictionary]{
//                for (key,value) in value1{
//                    let valueDict:[String:AnyObject] = value as! [String:AnyObject]
//
//                    let country:String = valueDict["destination"] as! String
//                    let startDate:Double = valueDict["departdate"] as! Double
//                    let endDate:Double = valueDict["returndate"] as! Double
//
//                    let order:CustomerList = CustomerList.init(eventKey: key, countryName: country, startDate: startDate, endDate: endDate)
//                    self.customerListArray.append(order)
//                }
//            }
          //  self.tableView.reloadData()
        })
        
        //tableView.estimatedRowHeight  = 88
       // tableView.rowHeight = UITableViewAutomaticDimension
    }

    @IBAction func cancelBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        let curriorCompany = curriorTextField.text ?? ""
        let trackingNum = TrackingNumLabel.text ?? ""
        let weight = weightLabel.text ?? ""
        let price = priceLabel.text ?? ""
        
        var dataToInsert = ["curriorCompany":curriorCompany,
                            "trackingNum":trackingNum,
                            "weight":weight,
                            "price":price,
                            "userid":selectedCustomerBuyInfo.userID,
                            "sellerid":userID!,
                            "orderid":selectedCustomerBuyInfo.orderID]
        
        ref.child("secondPayment").child("\(userID!)/\(selectedCustomerBuyInfo.orderID)").setValue(dataToInsert)
        
        if price != ""{
            //1 mean pending
             ref.child("secondPayment").child("\(userID!)/\(selectedCustomerBuyInfo.orderID)/paidStatus").setValue("1")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
