//
//  MyCustomerListViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 11/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class MyCustomerListViewController: UITableViewController {

    var ref:DatabaseReference!
    let userID:String? = Auth.auth().currentUser?.uid
    var customerListArray:[CustomerList] = [CustomerList]()
    var valueToPass:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        configureDatabase()
        
        title = "My Customer Order List"
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
        let countryLabel:UILabel = cell.viewWithTag(100) as! UILabel
        let dateLabel:UILabel = cell.viewWithTag(101) as! UILabel
        
        let contryName:String = customerListArray[indexPath.row].countryName
        let startDate:Double = customerListArray[indexPath.row].startDate
        let endDate:Double = customerListArray[indexPath.row].endDate
        
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
                    
                    let order:CustomerList = CustomerList.init(eventKey: key, countryName: country, startDate: startDate, endDate: endDate)
                    self.customerListArray.append(order)
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
        valueToPass = customerListArray[indexPath.row].eventKey
        print("asdadad\(valueToPass)")
        let cell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showCustomerDetail", sender: cell)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCustomerDetail"{
            let destination:CustomerCheckListViewController = segue.destination as! CustomerCheckListViewController
            destination.eventID = valueToPass
            
        }
    }
    
}

