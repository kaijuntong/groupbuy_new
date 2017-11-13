//
//  ReviewRatingViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 02/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ReviewRatingViewController: UITableViewController {
    var sellerID: String!
    var ref:DatabaseReference!
    
    var commentArray =  [CommentObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        configureDatabase()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RatingCommentViewCell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! RatingCommentViewCell
        let item:CommentObject = commentArray[indexPath.row]
        
        let dateString:String = displayTimestamp(ts: item.submitDate)
        cell.userLabel.text  = "\(item.username) said"
        cell.commentLabel.text = "\(item.comment)"
        cell.dateLabel.text = "\(dateString)"
        cell.rateLabel.text = "rate: \(item.rate)"
        return cell
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func configureDatabase(){
        //ref.child("user_rating").child(self.sellerID!).observeSingleEvent(of: .value, with: {(snapshot) in
        ref.child("user_rating").child(self.sellerID!).observe(DataEventType.value, with: {(snapshot) in
            //get user value
            let value:NSDictionary? = snapshot.value as? NSDictionary
            if let value1 = value as? [String:NSDictionary]{
                //remove old array
                self.commentArray.removeAll()

                for (key,value) in value1{
                    if value["rating"] as! Int != 0{
                        let rate:Int = value["rating"] as! Int
                        let submitDate:Double = value["submitDate"] as! Double
                        
                        if let comment = value["comment"]{
                            let userdata = self.ref.child("users").child("\(key)").observeSingleEvent(of: .value, with: {
                                (snapshot) in
                                let value2:NSDictionary? = snapshot.value as? NSDictionary
                                if let value3 = value2 as? [String:String]{
                                    print(value3)
                                    if value3["email"] != ""{
                                        let email:String? = value3["email"]
                                        let commentItem:CommentObject = CommentObject.init(username: email!, comment: comment as! String, rate:rate, submitDate:submitDate)
                                        self.commentArray.append(commentItem)
                                        
                                    }else{
                                        let commentItem:CommentObject = CommentObject.init(username: key, comment: comment as! String, rate:rate, submitDate:submitDate)
                                        self.commentArray.append(commentItem)
                                    }
                                     self.tableView.reloadData()
                                    
                                    //                                    for(key1, value1) in value3{
                                    //                                        if value1["email"] != ""{
                                    //                                            let email = value1["email"]
                                    //                                            let commentItem = CommentObject.init(username: email as! String, comment: comment as! String)
                                    //                                            self.commentArray.append(commentItem)
                                    //
                                    //                                        }else{
                                    //                                           let  commentItem = CommentObject.init(username: key, comment: comment as! String)
                                    //                                            self.commentArray.append(commentItem)
                                    //                                        }
                                    //                                    }
                                }
                            })
                            
                            //  let commentItem = CommentObject.init(username: key, comment: value["comment"] as! String)
                            // self.commentArray.append(commentItem)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
    
    func displayTimestamp(ts: Double) -> String {
        let date:Date = Date(timeIntervalSince1970: ts)
        let formatter:DateFormatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}
