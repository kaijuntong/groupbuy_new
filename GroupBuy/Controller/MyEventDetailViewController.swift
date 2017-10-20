//
//  MyEventDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 18/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class MyEventDetailViewController: UITableViewController {
    var ref:DatabaseReference!
    var eventID:String!
    var countryName:String!
    var eventItems = [Item]()
    
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = countryName
        configureDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configureDatabase(){
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid

            //listen for new messages in the firebase database
            _refHandle = ref.child("eventItems").queryOrdered(byChild: "uid").queryEqual(toValue: uid).observe(.childAdded){
                (snapshot:DataSnapshot) in
                
                let a = snapshot.value as? [String:String] ?? [:]
                
                let itemName = a["itemName"]
                let itemSize = a["itemSize"]
                let itemDescription = a["itemDescription"] ?? ""
                let itemPrice = a["itemPrice"]
                let itemImage = a["itemImage"]
                
                //create item object
                let item = Item(itemName: itemName!, itemDescription: itemDescription, itemPrice: Double(itemPrice!)!, itemSize: itemSize!,imageLoc: itemImage!)
                
                
                self.eventItems.append(item)
                self.test()
                self.tableView.reloadData()
//                    //self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1 , section: 0)], with: .automatic)
                }
            }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return eventItems.count
        return eventItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell" , for: indexPath)
        
        let itemName = eventItems[indexPath.row].itemName
        let imageURL = eventItems[indexPath.row].imageLoc
        let itemPrice = eventItems[indexPath.row].price
        
        let nameLabel = cell.viewWithTag(101) as! UILabel
        let itemImageView = cell.viewWithTag(100) as! UIImageView
        let priceLabel = cell.viewWithTag(102) as! UILabel
        
        nameLabel.text = itemName
        priceLabel.text = String(itemPrice)
        
        if imageURL.hasPrefix("gs://") {
            Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    itemImageView.image = UIImage.init(data: data!)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewItem"{
            let controller = segue.destination as! UINavigationController
            let itemVC = controller.topViewController as! ItemViewController
            itemVC.eventID = eventID
        }
    }
    
    func test(){
        for i in eventItems{
            print(i)
        }
    }
}
