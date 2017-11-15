//
//  ChatDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ChatDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var ref:DatabaseReference!
    var userID:String? = Auth.auth().currentUser?.uid
    var otherSideUserID: String! //"3spKLXDpAROOpbLm3qIiEb1aCAh2" //wITAg0SMJyYiwWhwqC7iH0L6aR32"
    var firstTime = false
    var chatItemArray = [ChatItem]()
    var postID = ""
    var chatID:String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(otherSideUserID!)
        ref = Database.database().reference()
        
        print("Test")
        print("\(userID!)")
        ref.child("chatPerson/\(userID!)").queryOrdered(byChild: "with").queryEqual(toValue: otherSideUserID).observeSingleEvent(of: .value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject]
            
            print("adadadadad")
            if a == nil{
                self.firstTime = true
                let postRef:DatabaseReference = self.ref.child("chat").childByAutoId()
                let chatConnectionData = [self.userID! : self.otherSideUserID]
                postRef.setValue(chatConnectionData)

                self.postID = postRef.key
            }else{
                self.ref.child("chat").queryOrdered(byChild: self.userID!).queryEqual(toValue: self.otherSideUserID).observeSingleEvent(of: .value, with: {(snapshot) in
                    let a = snapshot.value as? [String:AnyObject]

                    if a == nil{
                        self.ref.child("chat").queryOrdered(byChild: self.otherSideUserID).queryEqual(toValue: self.userID!).observeSingleEvent(of: .value, with: {(snapshot1) in
                            
                            let b = snapshot1.value as? [String:AnyObject]

                            for (key,_) in b!{
                                self.postID = key
                            }
                        })
                    }else{
                        for (key,_) in a!{
                            self.postID = key
                        }
                    }

                })
            }
            print(self.postID)
            print("asdadasdad")
            self.configureDatabase()

        })
        
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        tableView.tableFooterView = UIView(frame:.zero)
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        
        var cellNib:UINib = UINib(nibName: "chatFromCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "chatFromCell")
        
        cellNib = UINib(nibName: "chatToCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "chatToCell")

        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatDetailViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatDetailViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.estimatedRowHeight = 44.0
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatItemArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageItem = chatItemArray[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "chatFromCell", for: indexPath)

        if messageItem.from as! String == "\(userID!)"{
            cell = tableView.dequeueReusableCell(withIdentifier: "chatToCell", for: indexPath)
        }
        
        cell.backgroundColor = UIColor.clear
        // Configure the cell...

        let msg = cell.viewWithTag(101) as! UILabel
        let dateLabel = cell.viewWithTag(102) as! UILabel
        
        msg.text = messageItem.message as! String
        dateLabel.text = displayTimestamp(ts: messageItem.date)
        return cell
    }

    @objc func keyboardWillShow(notification:NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @IBAction func sendBtn(_ sender: UIButton) {
        if firstTime{
            self.tableView.reloadData()
        }
        messageTextField.resignFirstResponder()
        let message = messageTextField.text
        messageTextField.text = ""
        if message != ""{
            if firstTime{
                ref.child("chatPerson").child("\(userID!)").child("\(postID)/with").setValue("\(otherSideUserID!)")
                ref.child("chatPerson").child("\(otherSideUserID!)").child("\(postID)/with").setValue("\(userID!)")
            }
            
            let submitDate:Int = Int(Date.init().timeIntervalSince1970)
            let messageData = ["message":message, "from":userID!,"date":submitDate] as [String : Any]
            
            ref.child("chat/\(postID)/last_message").setValue(message)
            ref.child("chat/\(postID)/date").setValue(submitDate)
            ref.child("chatMessage/\(postID)").childByAutoId().setValue(messageData)
        }

    }
    @objc func keyboardWillHide(notification:NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func configureDatabase(){
        ref.child("chatMessage/\(postID)").observe(.childAdded, with: {(snapshot) in
         
            let value = snapshot.value as? [String:AnyObject]
            print(value)
            print("-asd-adas-d-")
            if let value = value{
                
                let from = value["from"] as! String
                let message = value["message"] as! String
                let date = value["date"] as! Double
                
                let chatItem = ChatItem.init(from: from, message: message, date: date)
                self.chatItemArray.append(chatItem)
                
                self.tableView.reloadData()
                }
            
            
        })
    }
    
    func displayTimestamp(ts: Double) -> String {
        let date:Date = Date(timeIntervalSince1970: ts)
        let formatter:DateFormatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
}
