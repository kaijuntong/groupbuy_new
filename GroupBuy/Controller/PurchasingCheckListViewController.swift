//
//  PurchasingCheckListViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 09/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class PurchasingCheckListViewController: UITableViewController {

    //var checklistArray = [Checklist]()
    var ref:DatabaseReference!
    var userID =  Auth.auth().currentUser?.uid
    var eventID:String!
    var purchasingListArray = [PurchasingChecklistItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        configureDatabase()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return purchasingListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let nameLabel = cell.viewWithTag(100) as! UILabel
        let quantityLabel = cell.viewWithTag(101) as! UILabel
        let checkedLabel = cell.viewWithTag(102) as! UILabel

        checkedLabel.text = purchasingListArray[indexPath.row].checked ? "✓" : ""
        nameLabel.text = "\(purchasingListArray[indexPath.row].itemName)"
        quantityLabel.text = "x \(purchasingListArray[indexPath.row].quantity)"
        return cell
    }
    
    func configureDatabase(){
        ref.child("purchasing_list").child("\(eventID!)").observeSingleEvent(of:.value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            
            if let value1 = a as? [String:NSDictionary]{
                for (itemID,value) in value1{
                    
                    let valueDict = value as! [String:AnyObject]
                    //let itemDict = valueDict as! [String:AnyObject]

                    let quantityDict = valueDict["buyer_info"] as! [String:Int]
                    let status = valueDict["status"] as? Int ?? 0
                    let checked = (status == 1 ? true:false)
                    
                    var quantity = 0
                    
                    for (key,value) in quantityDict{
                        let v = value as! Int
                        quantity += v
                    }
                    
                    self.ref.child("eventItems").child("\(itemID)").observeSingleEvent(of: .value, with: {
                        (snapshot) in
                        let value2 = snapshot.value as? NSDictionary
                        if let value3 = value2 as? [String:AnyObject]{
                            //print(value3)
                            let itemName = value3["itemName"] as! String

                            let purchasingItem = PurchasingChecklistItem.init(eventID:self.eventID!, itemID:itemID, itemName: itemName, quantity: quantity,checked: checked)
                            self.purchasingListArray.append(purchasingItem)
                        }
                        self.tableView.reloadData()
                    })
                }
                self.tableView.reloadData()
            }
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let item = purchasingListArray[indexPath.row]
        
            item.toogleChecked()
            configureCheckmark(for: cell, with: item)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklistItem"{
            let destination = segue.destination as! UINavigationController
            let detailVC = destination.topViewController as! ChecklistDetailViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                detailVC.itemID = purchasingListArray[indexPath.row].itemID
                detailVC.title = purchasingListArray[indexPath.row].itemName
            }
            
        }
    }
    
    func configureCheckmark(for cell:UITableViewCell, with item:PurchasingChecklistItem){
        let label = cell.viewWithTag(102) as! UILabel
        
        if item.checked{
            label.text = "✓"
        }else{
            label.text = ""
        }
    }
    
}
