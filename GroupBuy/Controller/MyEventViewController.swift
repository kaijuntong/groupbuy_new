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
    var parsedResult:[String:AnyObject]?
    
    var country:[MyCountry] = [MyCountry]()
    var eventDetails:[[String:Any]] = [[String:Any]]()
    
    //fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 176
        tableView.rowHeight = UITableViewAutomaticDimension
        parsedResult = [String:AnyObject]()
        configureDatabase()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.parsedResult?.removeAll()
//        country.removeAll()
//        configureDatabase()
//    }
    func configureDatabase(){
        ref = Database.database().reference()
        let user:User? = Auth.auth().currentUser
        if let user = user {
            let uid:String = user.uid
            //listen for new messages in the firebase database
            //ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: {(snapshot) in
            ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.value){(snapshot) in
                self.parsedResult?.removeAll()
                self.country.removeAll()
                self.parsedResult = snapshot.value as? [String:AnyObject]
                self.assignValue()
                self.tableView.reloadData()
            }
        }
        
    }
    
    func assignValue(){
        if let parsedResult = parsedResult{
            for (key,value) in parsedResult{
                print(value)
                let eventKey:String = key
                let countryName:String = value["destination"] as! String
                let startDate:Double = value["departdate"] as! Double
                let dueDate:Double = value["returndate"] as! Double
                
                let eventDetail:[String:Any] = ["destination": countryName,
                                   "departdate": startDate,
                                   "returndate": dueDate] as [String : Any]
                
                
                eventDetails.append(eventDetail)
                //create item object
                let mycountry:MyCountry = MyCountry(eventKey: eventKey, countryName: countryName, startDate: startDate, dueDate: dueDate, countryImage: "")
                
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
        let cell:MyEventViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyEventViewCell
        
        let selectedCountry:MyCountry = country[indexPath.row]
        
        let countryName:String = selectedCountry.countryName.lowercased()
        let startDate:Double = selectedCountry.startDate
        let dueDate:Double = selectedCountry.dueDate
        
        let a:String = displayTimestamp(ts: startDate)
        let b:String = displayTimestamp(ts: dueDate)
        cell.countryLabel.text = countryName.capitalized
        cell.dateLabel.text = "\(a) - \(b)".capitalized
        cell.countryImageView.image = UIImage(named:"\(countryName)")
        return cell
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
        if segue.identifier == "showEventDetail"{
            let controller:MyEventDetailViewController = segue.destination as! MyEventDetailViewController
            
            if let indexPath:IndexPath = tableView.indexPath(for: sender as! UITableViewCell){
                //controller.itemToEdit = checklist.items[indexPath.row]
                
                let parentKey:String = country[indexPath.row].eventKey
                
                controller.eventID = parentKey
                controller.countryName = country[indexPath.row].countryName
                controller.eventDetail = eventDetails[indexPath.row]
                print(parentKey)
            }
        }
    }
}
