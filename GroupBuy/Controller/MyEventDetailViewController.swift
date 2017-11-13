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
    var eventDetail:[String:Any]!
    
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
        let user:User? = Auth.auth().currentUser
        if let user = user {
            let uid:String = user.uid
            
            //listen for new messages in the firebase database
            _refHandle = ref.child("eventItems").queryOrdered(byChild: "event_id").queryEqual(toValue: eventID).observe(.value){
                (snapshot:DataSnapshot) in
                print(snapshot)
                
                //remove previous data
                self.eventItems.removeAll()
                let a = snapshot.value as? [String:AnyObject] ?? [:]
                //
                
                for (key,value) in a{
                    let abc:[String:AnyObject] = value as![String:AnyObject]
                    
                    let itemName:String = abc["itemName"] as! String
                    let itemSize:String = abc["itemSize"] as! String
                    let itemDescription:String = abc["itemDescription"] as! String
                    let itemPrice:Double = abc["itemPrice"] as! Double
                    let itemImage:String = abc["itemImage"] as! String
                    let sellerID:String = abc["uid"] as! String
                    //create item object
                    let item:Item = Item(itemKey:key, itemName: itemName, itemDescription: itemDescription, itemPrice: itemPrice, itemSize: itemSize,imageLoc: itemImage)
                    
                    self.eventItems.append(item)
                }
                self.test()
                self.tableView.reloadData()
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
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:"Cell" , for: indexPath)
        
        let itemName:String = eventItems[indexPath.row].itemName
        let imageURL:String = eventItems[indexPath.row].imageLoc
        let itemPrice:Double = eventItems[indexPath.row].price
        
        let nameLabel:UILabel = cell.viewWithTag(101) as! UILabel
        let itemImageView:UIImageView = cell.viewWithTag(100) as! UIImageView
        let priceLabel:UILabel = cell.viewWithTag(102) as! UILabel
        
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
            let controller:UINavigationController = segue.destination as! UINavigationController
            let itemVC:ItemViewController = controller.topViewController as! ItemViewController
            itemVC.eventID = eventID
            itemVC.eventDetail = eventDetail
        }
        if segue.identifier == "editItem"{
            let controller:UINavigationController = segue.destination as! UINavigationController
            let itemVC:ItemViewController = controller.topViewController as! ItemViewController
            
            itemVC.eventID = eventID
            itemVC.eventDetail = eventDetail
            
            if let indexPath:IndexPath = tableView.indexPath(for: sender as! UITableViewCell){
                itemVC.itemToEdit = eventItems[indexPath.row]
            }
        }
    }
    
    func test(){
        for i in eventItems{
            print(i)
        }
    }
}
