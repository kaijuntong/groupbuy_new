//
//  MyPurchasingListViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 09/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class MyPurchasingListViewController: UITableViewController {

    var ref:DatabaseReference!
    let userID:String? = Auth.auth().currentUser?.uid
    var purchasingListArray:[PurchasingList] = [PurchasingList]()
    var valueToPass:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        configureDatabase()
        
        title = "My Purchasing List"
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
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let countryLabel:UILabel = cell.viewWithTag(100) as! UILabel
        let dateLabel:UILabel = cell.viewWithTag(101) as! UILabel
        
        let contryName:String = purchasingListArray[indexPath.row].countryName
        let startDate:Double = purchasingListArray[indexPath.row].startDate
        let endDate:Double = purchasingListArray[indexPath.row].endDate
        
        let date:String = "\(displayTimestamp(ts:startDate)) - \(displayTimestamp(ts:endDate))"
        countryLabel.text = contryName
        dateLabel.text = date
        return cell
    }

    func configureDatabase(){
        ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: "\(userID!)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            
            if let value1 = a as? [String:NSDictionary]{
                for (key,value) in value1{
                    let valueDict:[String:AnyObject] = value as! [String:AnyObject]
                    
                    let country:String = valueDict["destination"] as! String
                    let startDate:Double = valueDict["departdate"] as! Double
                    let endDate:Double = valueDict["returndate"] as! Double
                    
                    let order:PurchasingList = PurchasingList.init(eventKey: key, countryName: country, startDate: startDate, endDate: endDate)
                    self.purchasingListArray.append(order)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueToPass = purchasingListArray[indexPath.row].eventKey
        print("asdadad\(valueToPass)")
        let cell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showPurchasingDetail", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPurchasingDetail"{
            let destination:PurchasingCheckListViewController = segue.destination as! PurchasingCheckListViewController
            destination.eventID = valueToPass
        }
    }
    
}
