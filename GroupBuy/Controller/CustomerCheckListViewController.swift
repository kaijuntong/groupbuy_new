//
//  CustomerCheckListViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 12/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class CustomerCheckListViewController: UITableViewController {
    
    
    //var checklistArray = [Checklist]()
    var ref:DatabaseReference!
    var userID:String? =  Auth.auth().currentUser?.uid
    var eventID:String!
    var customerListArray:[CustomerBuyInfo] = [CustomerBuyInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(eventID)
        ref = Database.database().reference()
        
        configureDatabase()
        tableView.estimatedRowHeight  = 88
      //  tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customerListArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let itemLabel:UILabel = cell.viewWithTag(100) as! UILabel
//        let addressLabel:UILabel = cell.viewWithTag(101) as! UILabel
//        let emailLabel:UILabel = cell.viewWithTag(102) as! UILabel
//
//        let checkedLabel:UILabel = cell.viewWithTag(105) as! UILabel
//        print("------")
//        print(customerListArray[indexPath.row].checked)
//        print("------")
//        checkedLabel.text = customerListArray[indexPath.row].checked ? "✓" : ""
//
//        var itemString:String = ""
//
//        let customerBuyItemArray:[CustomerBuyItem] = customerListArray[indexPath.row].itemInfo
//
//        for i in customerBuyItemArray{
//            itemString += i.itemName
//            itemString += "\tx\(i.itemQuantity)\n"
//            itemLabel.text = itemString
//        }
//
//        emailLabel.text = customerListArray[indexPath.row].email
//        addressLabel.text = customerListArray[indexPath.row].address
//        return cell
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let emailLabel:UILabel = cell.viewWithTag(101) as! UILabel
        let orderIdLabel:UILabel = cell.viewWithTag(102) as! UILabel
        let paidStatusLabel:UILabel = cell.viewWithTag(100) as! UILabel
        
        ref.child("secondPayment/\(userID!)/\(customerListArray[indexPath.row].orderID)/paidStatus").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? String ?? ""
            if value == "2"{
                paidStatusLabel.text = "Paided"
            }else if value == "1"{
                paidStatusLabel.text = "Pending"
            }else{
                paidStatusLabel.text = "Unpaid"
            }
        })
        
        emailLabel.text = customerListArray[indexPath.row].email
        orderIdLabel.text = customerListArray[indexPath.row].orderID
        
        return cell
    }
    
    var customerBuyItemsArray:[CustomerBuyItem] = [CustomerBuyItem]()
    
    func configureDatabase(){
        ref.child("customerlist/\(eventID!)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)

            if let orderDict = a as? [String:NSDictionary]{
                 for (orderID,orderDetail) in orderDict{
                    if let userDict = orderDetail as? [String:NSDictionary]{
                        for (userID, userDetail) in userDict{
                            let itemInfo = userDetail["itemInfo"] as! [String:AnyObject]
                           
                            var itemInfoArray = [CustomerBuyItem]()
                            
                            for (itemKey, itemInfo) in itemInfo{
                                let itemName = itemInfo["itemName"] as! String
                                let itemQuantity = itemInfo["itemQuantity"] as! Int
                                
                                let itemInfo = CustomerBuyItem.init(itemKey: itemKey , itemQuantity: itemQuantity, itemName: itemName)
                                itemInfoArray.append(itemInfo)
                            }
                            
                            let status:Int = userDetail["status"] as? Int ?? 0
                            let checked:Bool = (status == 1 ? true:false)
                            
                            let userAddress = userDetail["userAddress"] as! String
                            let userEmail = userDetail["userEmail"] as! String
                            
                            print(userAddress)
                            print("...../.....")
                            
                            
                            //let customerBuyInfo = CustomerBuyInfo.init(address: userAddress, itemInfo: itemInfoArray, email:userEmail, checked:checked)
                            
                            let customerBuyInfo = CustomerBuyInfo.init(eventID: self.eventID!, orderID: orderID, userID: userID, address: userAddress, itemInfo: itemInfoArray, email: userEmail, checked: checked)
                            self.customerListArray.append(customerBuyInfo)
                        }
                    }
                }
                self.customerListArray.sort{$0 < $1}
                self.tableView.reloadData()
            }
            print("Done")
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secondPaymentVC"{
            print("Hello")
            let destination:UINavigationController = segue.destination as! UINavigationController
            let secondPaymentVC:secondPaymentViewController = destination.topViewController as! secondPaymentViewController
            
            print("text")
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                print("Hello")
                secondPaymentVC.selectedCustomerBuyInfo = customerListArray[indexPath.row]
            }
        }
    }
    
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell:UITableViewCell = tableView.cellForRow(at: indexPath){
//            let item:CustomerBuyInfo = customerListArray[indexPath.row]
//
//            item.toogleChecked()
//            configureCheckmark(for: cell, with: item)
//        }
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
//    func configureCheckmark(for cell:UITableViewCell, with item:CustomerBuyInfo){
//        let label:UILabel = cell.viewWithTag(105) as! UILabel
//
//        if item.checked{
//            label.text = "✓"
//        }else{
//            label.text = ""
//        }
//    }

}
