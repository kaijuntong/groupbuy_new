//
//  MyOrderlistViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 08/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class MyOrderlistViewController: UITableViewController {

    var ref:DatabaseReference!
    let userID:String? =  Auth.auth().currentUser?.uid
    var orderListArray:[Orderlist] = [Orderlist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        configureDatabase()
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
        return orderListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let keyLabel:UILabel = cell.viewWithTag(100) as! UILabel
        keyLabel.text = orderListArray[indexPath.row].key
        
        let priceLabel:UILabel = cell.viewWithTag(101) as! UILabel
        priceLabel.text = "\(orderListArray[indexPath.row].paymentPrice)"
        
        let orderDateLabel:UILabel = cell.viewWithTag(102) as! UILabel
        orderDateLabel.text = self.displayTimestamp(ts:  orderListArray[indexPath.row].orderDate)
        return cell
    }
    
    func configureDatabase(){
        ref.child("orderlist").queryOrdered(byChild: "buyer_id").queryEqual(toValue: "\(userID!)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            
            if let value1 = a as? [String:NSDictionary]{
                for (key,value) in value1{
                    let valueDict:[String:AnyObject] = value as! [String:AnyObject]
                    

                    let orderDate:Double = valueDict["order_date"] as! Double
                    let paymentPrice:Double = valueDict["paymentPrice"] as! Double
                    
                    let order:Orderlist = Orderlist.init(key: key, orderDate: orderDate, paymentPrice: paymentPrice)
                    //print("\(key), \(orderDate), \(paymentPrice),\(a)")
                    self.orderListArray.append(order)
                }
            }
            self.tableView.reloadData()
        })
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
