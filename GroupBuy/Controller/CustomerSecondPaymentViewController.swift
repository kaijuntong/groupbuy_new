//
//  CustomerSecondPaymentViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 23/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class CustomerSecondPaymentViewController: UITableViewController {
    var ref:DatabaseReference!
    var userID:String? =  Auth.auth().currentUser?.uid
    var sellerIDSet: Set<String>!
    var sellerIDArray = [String]()
    var orderKey:String!
    var sellerArray = [CustomerSecondPaymentItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        for sellerID in sellerIDSet{
            sellerIDArray.append(sellerID)
        }
        
        print(orderKey)
        print(sellerIDArray)
        
//        for i in 0..<sellerIDArray.count{
//            ref.child("secondPayment/\(sellerIDArray[i])/\(orderKey!)").observeSingleEvent(of: .value, with: {(snapshot) in
//                let value = snapshot.value as? [String:String] ?? [:]
//
//                let status = value["paidStatus"] ?? ""
////                if status == "2"{
////                    cell.payStatusLabel.text = "Paid"
////                }else if status == "1"{
////                    cell.payStatusLabel.text = "Pending..."
////                }else{
////                    cell.payStatusLabel.text = "Unpaid"
////                }
//
//                let price = value["price"] ?? ""
//                let currior = value["curriorCompany"] ?? ""
//                let trackingNum = value["trackingNum"] ?? ""
//                let weight = value["weight"] ?? ""
//
//                let item = CustomerSecondPaymentItem.init(status: status, trackingNum: trackingNum, curriorCompany: currior, weight: weight, price: price, sellerId: self.sellerIDArray[i], orderID: self.orderKey)
//
//                self.sellerArray.append(item)
//                self.tableView.reloadData()
//            })
//        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDatabase()
    }
    func configureDatabase(){
        sellerArray.removeAll()
        for i in 0..<sellerIDArray.count{
            ref.child("secondPayment/\(sellerIDArray[i])/\(orderKey!)").observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? [String:String] ?? [:]
                
                
                let status = value["paidStatus"] ?? ""
                //                if status == "2"{
                //                    cell.payStatusLabel.text = "Paid"
                //                }else if status == "1"{
                //                    cell.payStatusLabel.text = "Pending..."
                //                }else{
                //                    cell.payStatusLabel.text = "Unpaid"
                //                }
                
                let price = value["price"] ?? ""
                let currior = value["curriorCompany"] ?? ""
                let trackingNum = value["trackingNum"] ?? ""
                let weight = value["weight"] ?? ""
                
                let item = CustomerSecondPaymentItem.init(status: status, trackingNum: trackingNum, curriorCompany: currior, weight: weight, price: price, sellerId: self.sellerIDArray[i], orderID: self.orderKey)
                
                self.sellerArray.append(item)
                self.tableView.reloadData()
            })
        }
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
        return sellerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! customerSecondPaymentCell
        
        self.ref.child("users/\(sellerArray[indexPath.row].sellerId)/email").observeSingleEvent(of: .value, with: {(snapshot) in
            let email = snapshot.value as? String ?? ""
            
            cell.sellerLabel.text = email
        })
            
        //print("\(sellerIDArray[indexPath.row])/\(orderKey!)")
        let status = sellerArray[indexPath.row].status
        if status == "2"{
            cell.payStatusLabel.text = "Paided"
            cell.accessoryType = .none
        }else if status == "1"{
            cell.payStatusLabel.text = "Pending"
        }else{
            cell.payStatusLabel.text = "UnPaid"
             cell.accessoryType = .none
        }
        
        cell.priceLabel.text = "Price RM \(sellerArray[indexPath.row].price)"
        cell.curriorLabel.text = "Currior Company \(sellerArray[indexPath.row].curriorCompany)"
        cell.trackingNumberLabel.text = "Tracking Number \(sellerArray[indexPath.row].trackingNum)"
        cell.weightLabel.text = "Weight \(sellerArray[indexPath.row].weight)"
        
        return cell
    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeSecondPayment"{
            print("Hello123")
            let secondPaymentVC:CustomerMakeSecondPaymentViewController = segue.destination as! CustomerMakeSecondPaymentViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                print("Hello123")
                print(orderKey!)
                secondPaymentVC.orderID = orderKey!
                secondPaymentVC.sellerID = sellerArray[indexPath.row].sellerId
            }
        }
    }
    
}
