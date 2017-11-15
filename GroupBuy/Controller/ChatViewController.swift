//
//  ChatViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UITableViewController {

    var ref:DatabaseReference!
    var userID:String?
    var chatListArray = [ChatListItem]()
    var valueToPass = ""
    var destiantionTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        userID =  Auth.auth().currentUser?.uid

        print("Hello World")
       
    }

    override func viewDidAppear(_ animated: Bool) {
        configureDatabase()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Icomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatListArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        
        let username = cell.viewWithTag(101) as! UILabel
       
        
        ref.child("users/\(chatListArray[indexPath.row].otherPersonUserID)/email").observeSingleEvent(of: .value, with: {(snapshot) in
            let email = snapshot.value as? String
            
            if let email = email{
                username.text = email
            }
            })
        
        let lastMessageLabel = cell.viewWithTag(102) as! UILabel
        lastMessageLabel.text = chatListArray[indexPath.row].lastMessage
        
        let dateLabel = cell.viewWithTag(103) as! UILabel
        dateLabel.text = displayTimestamp(ts: chatListArray[indexPath.row].date)
        
        return cell
    }
    
    
    func configureDatabase(){
        
        ref.child("chatPerson/\(userID!)").observeSingleEvent(of: .value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject]
            self.chatListArray.removeAll()
            print(a)
            if let value = a{
                for(key,withValue) in value{
                    let otherPerson = withValue["with"] as! String
                    print(key)
                    self.ref.child("chat/\(key)").observeSingleEvent(of: .value, with: {(snap) in
                        let snapValue = snap.value as? [String:AnyObject]

                        print(snapValue)
                        print("aosdoaksdokaodkaodkaodkaodkaodkok")
                        if let snapValue = snapValue{
                            let lastMessage = snapValue["last_message"] as! String
                            let date = snapValue["date"] as! Double
                            let cartListItem = ChatListItem.init(chatID: key, otherPersonUserID: otherPerson, lastMessage: lastMessage, date:date)

                            self.chatListArray.append(cartListItem)

                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
    }
    
//        func configureDatabase(){
//            ref.child("chatPerson/\(userID!)").observe(.value, with: {(snapshot) in
//                let a = snapshot.value as? [String:AnyObject]
//
//                print(a)
//                if let value = a{
//                    for(key,withValue) in value{
//                        let otherPerson = withValue["with"] as! String
//                        print(key)
//                        self.ref.child("chat/\(key)").observeSingleEvent(of: .value, with: {(snap) in
//                            let snapValue = snap.value as? [String:AnyObject]
//
//                            print(snapValue)
//                            print("aosdoaksdokaodkaodkaodkaodkaodkok")
//                            if let snapValue = snapValue{
//                                let lastMessage = snapValue["last_message"] as! String
//                                let date = snapValue["date"] as! Double
//                                let cartListItem = ChatListItem.init(chatID: key, otherPersonUserID: otherPerson, lastMessage: lastMessage, date:date)
//
//                                self.chatListArray.append(cartListItem)
//
//                                self.tableView.reloadData()
//                            }
//                        })
//                    }
//                }
//            })
//        }

    
    func displayTimestamp(ts: Double) -> String {
        let date:Date = Date(timeIntervalSince1970: ts)
        let formatter:DateFormatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueToPass = chatListArray[indexPath.row].chatID
        destiantionTitle = chatListArray[indexPath.row].otherPersonUserID
        let cell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showChatDetail", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatDetail"{
            let destination:ChatDetailViewController = segue.destination as! ChatDetailViewController
            destination.chatID = valueToPass
            destination.otherSideUserID = destiantionTitle
            destination.title = destiantionTitle
            destination.postID = destiantionTitle
        }
        
    }
    
    


}
