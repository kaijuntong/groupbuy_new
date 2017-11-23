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
    var valueToPass:ChatListItem?
    var destiantionTitle = ""
    var profileImageData:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        userID =  Auth.auth().currentUser?.uid
        
        //get profile image
        ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            let value:NSDictionary? = snapshot.value as? NSDictionary
            let profilePic = value?["profilePicture"] as? String ?? ""
            if profilePic.hasPrefix("gs://") {
                Storage.storage().reference(forURL: profilePic).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileImageData = data!
                    }
                }
            }
        })
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        let profileImageView = cell.viewWithTag(100) as! UIImageView
        profileImageView.image = UIImage(named: "user_male")
        
        if chatListArray[indexPath.row].otherPersonImage.hasPrefix("gs://") {
            Storage.storage().reference(forURL: chatListArray[indexPath.row].otherPersonImage).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                
                print("------")
                print(data)
                DispatchQueue.main.async {
                    self.chatListArray[indexPath.row].imageData = data!
                    profileImageView.image = UIImage.init(data: data!)
                }
                
            }
        }
        
        
        let username = cell.viewWithTag(101) as! UILabel
        username.text = chatListArray[indexPath.row].username
        
        
        let lastMessageLabel = cell.viewWithTag(102) as! UILabel
        lastMessageLabel.text = chatListArray[indexPath.row].lastMessage
        
        let dateLabel = cell.viewWithTag(103) as! UILabel
        dateLabel.text = displayTimestamp(ts: chatListArray[indexPath.row].date)
        
        
        
        return cell
    }
    
    func configureDatabase(){
        self.chatListArray.removeAll()
        self.tableView.reloadData()
        
        //get who is chatting with user
        ref.child("chatPerson/\(userID!)").observeSingleEvent(of: .value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject]
            
            if let value = a{
                for(key,withValue) in value{
                    let otherPerson = withValue["with"] as! String
                    print(key)
                    
                    //get the chat message, date, last message
                    self.ref.child("chat/\(key)").observeSingleEvent(of: .value, with: {(snap) in
                        
                        let snapValue = snap.value as? [String:AnyObject]
                        
                        if let snapValue = snapValue{
                            let lastMessage = snapValue["last_message"] as! String
                            let date = snapValue["date"] as! Double
                            
                            self.ref.child("users/\(otherPerson)/email").observeSingleEvent(of: .value, with: {(snapshot) in
                                let email = snapshot.value as? String
                                
                                
                                if let email = email{
                                    self.ref.child("users/\(otherPerson)/profilePicture").observeSingleEvent(of: .value, with: {(snapshot) in
                                        let imageLoc = snapshot.value as? String ?? ""
                                        
                                        let cartListItem = ChatListItem.init(chatID: key, otherPersonUserID: otherPerson, lastMessage: lastMessage, date:date, username:email, otherPersonImage:imageLoc, imageData: nil)
                                        
                                        self.chatListArray.append(cartListItem)
                                        self.chatListArray.sort{$0 > $1}
                                        self.tableView.reloadData()
                                    })
                                }
                            })
                            
                        }
                    })
                }
            }
        })
    }
    
    
    func displayTimestamp(ts: Double) -> String {
        let date:Date = Date(timeIntervalSince1970: ts)
        let formatter:DateFormatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueToPass = chatListArray[indexPath.row]
        
        let cell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "showChatDetail", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatDetail"{
            let destination:ChatDetailViewController = segue.destination as! ChatDetailViewController
            destination.chatID = valueToPass!.chatID
            destination.otherSideUserID = valueToPass!.otherPersonUserID
            destination.title = valueToPass!.username
            destination.postID = valueToPass!.chatID
            destination.otherSideProfileImage = valueToPass!.imageData
            destination.selfProfileImage = profileImageData
        }
        
    }
    
    
    
    
}
