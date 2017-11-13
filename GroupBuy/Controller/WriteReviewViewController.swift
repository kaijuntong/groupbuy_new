//
//  WriteReviewViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 10/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class WriteReviewViewController: UITableViewController,RatingControlDelegate {
    
    @IBOutlet weak var ratingStackView: RatingControl!
    @IBOutlet weak var commentTextField: UITextField!
    
    var ref:DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var rating:Int?
    var comment:String?
    
    var dataToInsert:[String:Any]?
    
    var submitDate:Date = Date()
    
    var sellerID: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.ratingStackView.delegate = self

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnClicked(_ sender: UIBarButtonItem) {
        if let rating = rating{
            if let comment = commentTextField.text{
                dataToInsert = ["rating":rating,
                             "comment": comment]
            }else{
                dataToInsert = ["rating":rating]
            }
            let submiTimeInterval:Int = Int(submitDate.timeIntervalSince1970)
            dataToInsert!["submitDate"] = submiTimeInterval
            
            ref.child("user_rating/\(sellerID!)/\(userID!)").updateChildValues(dataToInsert!)
            dismiss(animated: true, completion: nil)
        }else{
            let alertController:UIAlertController = UIAlertController(title: "Error", message: "The rate and review cannot be empty", preferredStyle: .alert)
            let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
       
    }
    
    func ratingPicker(_ picker: RatingControl, didPick rating: Int) {
        self.rating = rating
        //let array = ["rating":rating]
        //ref.child("user_rating/\(sellerID!)/\(userID!)").updateChildValues(array)
    }
    
}
