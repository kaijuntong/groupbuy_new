//
//  MyEventViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 16/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase
class MyEventViewController: UITableViewController {
    var ref:DatabaseReference!
    var messages: [DataSnapshot]! = []
    var parsedResult:[String:AnyObject]!
    
    var country = [MyCountry]()
    
    //fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 176
        tableView.rowHeight = UITableViewAutomaticDimension
        parsedResult = [:]
        configureDatabase()
    }
    func configureDatabase(){
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            //listen for new messages in the firebase database
            //ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: {(snapshot) in
            ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.value){(snapshot) in
                self.parsedResult.removeAll()
                self.parsedResult = snapshot.value as? [String:AnyObject]
                self.assignValue()
                self.tableView.reloadData()
            }
            
            //        ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observeSingleEvent(of: .value){(snapshot:DataSnapshot) in
            //            let a = snapshot.value as? NSDictionary
            //
            //            let eventKey = snapshot.key
            //            let countryName = a?["destination"] as? String ?? ""
            //            print("------------")
            //            print(countryName)
            //                print("------------")
            //           // let startDate = a["departdate"] as! Double
            //////            let dueDate = a["returndate"] as! Double
            //////            print("------------------")
            //////            print(eventKey)
            //////
            //////            print(startDate)
            //////            print(dueDate)
            //////            print("------------------")
            ////
            ////
            ////            //create item object
            ////            let mycountry = MyCountry(eventKey: eventKey, countryName: countryName, startDate: startDate, dueDate: dueDate, countryImage: "")
            ////
            ////            self.country.append(mycountry)
            //            self.tableView.reloadData()
            //        }
        }
        
    }
    
    func assignValue(){
        if let parsedResult = parsedResult{
        for (key,value) in parsedResult{
            print(value)
            let eventKey = key
            let countryName = value["destination"] as! String
            let startDate = value["departdate"] as! Double
            let dueDate = value["returndate"] as! Double
            
            //create item object
            let mycountry = MyCountry(eventKey: eventKey, countryName: countryName, startDate: startDate, dueDate: dueDate, countryImage: "")
            
            self.country.append(mycountry)
            }}
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        return 176
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return country.count
    }
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyEventViewCell
    
            let selectedCountry = country[indexPath.row]
    
            let countryName = selectedCountry.countryName.lowercased()
            let startDate = selectedCountry.startDate
            let dueDate = selectedCountry.dueDate
    
            let a = displayTimestamp(ts: startDate)
            let b = displayTimestamp(ts: dueDate)
            cell.countryLabel.text = countryName
            cell.dateLabel.text = "\(a) - \(b)"
            cell.countryImageView.image = UIImage(named:"\(countryName)")
            return cell
        }
    
    func displayTimestamp(ts: Double) -> String {
        let date = Date(timeIntervalSince1970: ts)
        let formatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetail"{
            let controller = segue.destination as! MyEventDetailViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                //controller.itemToEdit = checklist.items[indexPath.row]
                
                let parentKey = country[indexPath.row].eventKey
                
                controller.eventID = parentKey
                controller.countryName = country[indexPath.row].countryName
                
                print(parentKey)
            }
        }
    }
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let itemsCollectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "ItemsCollectionViewController") as! ItemsCollectionViewController
    //
    //        let currentCell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
    //        itemsCollectionViewController.eventId = currentCell.
    //        itemsCollectionViewController.countryName = currentCell.countryName.text
    //        print(currentCell.eventID)
    //
    //        self.navigationController!.pushViewController(itemsCollectionViewController, animated: true)
    //        tableView.deselectRow(at: indexPath, animated: false)
    //    }
}
