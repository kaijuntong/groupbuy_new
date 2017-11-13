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
    var customerListArray:[CustomerChecklistItem] = [CustomerChecklistItem]()
    
    var address:[String] = ["12 JALAN NJM 5/2, taman Nusa jaya mas, 81300 skudai, johor",
                   "12 JALasdadadadadsaddAN NJM 5/2, taman Nusa jaya mas, 81300 skudai, johor",
                   "12 JALAN NJM 5/2"]
    
    var testArray:[String] = [
        """
                    你好吗
                    不要
                    henasdad
                    """,
        """
                    你好吗
                    henasdaasjadnjandjkandjakndknsajndjkandjkandjnasjdkd
                    """,
        """
                    你好吗
                    不要
                    你好吗
                    不要
                    henasdad
                    henasdad
                    """
    ]
    var QuantityArray:[String] = [
        """
                    x12
                    x12
                    x12
                    """,
        """
                    x12
                    x12
                    """,
        """
                    x12
                    x12
                    x12
                    x12
                    x12
                    x12
                    """
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(eventID)
        ref = Database.database().reference()
        
        configureDatabase()
        tableView.estimatedRowHeight  = 88
        tableView.rowHeight = UITableViewAutomaticDimension
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
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let itemLabel:UILabel = cell.viewWithTag(100) as! UILabel
        let addressLabel:UILabel = cell.viewWithTag(101) as! UILabel
        
        var itemString:String = ""
        
        let customerBuyArray:[CustomerBuyItem] = customerListArray[indexPath.row].buyerItemArray
        
        for i in customerBuyArray{
            itemString += i.itemName
            itemString += "\tx\(i.itemQuantity)\n"
            itemLabel.text = itemString
        }
        
        addressLabel.text = address[indexPath.row]
        return cell
    }
    
    var customerBuyItemsArray:[CustomerBuyItem] = [CustomerBuyItem]()
    
    func configureDatabase(){
        ref.child("customer_list").child("\(eventID!)").observeSingleEvent(of:.value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            
            if let value1 = a as? [String:NSDictionary]{
                for (userID,value) in value1{
                    self.customerBuyItemsArray.removeAll()
                    
                    let valueDict:[String:AnyObject] = value as! [String:AnyObject]
                    //let itemDict = valueDict as! [String:AnyObject]
                    
                    let itemDict:[String:AnyObject] = valueDict["item_info"] as! [String:AnyObject]
                    let status:Int = valueDict["status"] as? Int ?? 0
                    let checked:Bool = (status == 1 ? true:false)
                    
                    
                    for (key,dictValue) in itemDict{
                        let customerBuyItem:CustomerBuyItem = CustomerBuyItem.init(itemKey: key, itemQuantity: dictValue["itemQuantity"] as! Int, itemName:dictValue["itemName"] as! String)
                        self.customerBuyItemsArray.append(customerBuyItem)
                    }
                    
                    let customerChecklistItem:CustomerChecklistItem = CustomerChecklistItem.init(userId: userID, buyerItemArray: self.customerBuyItemsArray, checked: checked)
                    
                    self.customerListArray.append(customerChecklistItem)
                    
                }
                self.tableView.reloadData()
            }
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
    //
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if let cell = tableView.cellForRow(at: indexPath){
    //            let item = purchasingListArray[indexPath.row]
    //
    //            item.toogleChecked()
    //            configureCheckmark(for: cell, with: item)
    //        }
    //        tableView.deselectRow(at: indexPath, animated: true)
    //    }
    //
    ////    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    ////        if segue.identifier == "showChecklistItem"{
    ////            let destination = segue.destination as! UINavigationController
    ////            let detailVC = destination.topViewController as! ChecklistDetailViewController
    ////
    ////            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
    ////                detailVC.itemID = purchasingListArray[indexPath.row].itemID
    ////                detailVC.title = purchasingListArray[indexPath.row].itemName
    ////            }
    ////
    ////        }
    ////    }
    //
    //    func configureCheckmark(for cell:UITableViewCell, with item:PurchasingChecklistItem){
    //        let label = cell.viewWithTag(102) as! UILabel
    //
    //        if item.checked{
    //            label.text = "✓"
    //        }else{
    //            label.text = ""
    //        }
    //    }
    
}
