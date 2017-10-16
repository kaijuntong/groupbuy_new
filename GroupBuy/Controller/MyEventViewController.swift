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
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 176
        tableView.rowHeight = UITableViewAutomaticDimension
        configureDatabase()
    }
    
    
    func configureDatabase(){
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
        
        //listen for new messages in the firebase database
        _refHandle = ref.child("events").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded){(snapshot:DataSnapshot) in
            self.messages.append(snapshot)
            self.tableView.reloadData()
            //self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1 , section: 0)], with: .automatic)
        }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        return 176
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Static Cell will be shown in a second row
        //        if indexPath.section == 0 && indexPath.row == 0 {
        //            var cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")
        //            cell?.selectionStyle = .none
        //            return cell!
        //        }
        
        //dynamic cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyEventViewCell
        
        //unpack message
        let messageSnapshot:DataSnapshot! = messages[indexPath.row]
       // let parentKey = messages[indexPath.row].key
        
        let message = messageSnapshot.value as! [String:AnyObject]
        print(message)
        print(message["destination"])
        let destination:String = message["destination"] as! String
        let departDate:Double = message["departdate"] as! Double
        let returnDate:Double = message["returndate"] as! Double
        
        //print(destination)
        cell.countryImageView.image = UIImage(named: destination.lowercased())
        //cell.eventID = parentKey
        cell.countryLabel.text = destination
        
        let startDate = displayTimestamp(ts: departDate)
        let redate = displayTimestamp(ts: returnDate)
        
        cell.dateLabel.text = "\(startDate) to \(redate)"
        
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
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let itemsCollectionViewController = self.storyboard!.instantiateViewController(withIdentifier: "ItemsCollectionViewController") as! ItemsCollectionViewController
//
//        let currentCell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
//        itemsCollectionViewController.eventId = currentCell.eventID
//        itemsCollectionViewController.countryName = currentCell.countryName.text
//        print(currentCell.eventID)
//
//        self.navigationController!.pushViewController(itemsCollectionViewController, animated: true)
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
}
