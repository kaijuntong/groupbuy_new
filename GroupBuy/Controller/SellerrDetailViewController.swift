//
//  SellerDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 26/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase
//RatingControlDelegate
class SellerDetailViewController: UITableViewController, RatingControlDelegate, WriteReviewViewControllerDelegate{
    var ref:DatabaseReference!
    let userID:String? = Auth.auth().currentUser?.uid
    var sellerID: String!
    var ratingPerson:Int = 0
    var ratingNumber:Int = 0
    var ratingValue:Double = 0.0

    var submitDate:Date = Date()
    var sellerImageData:Data?
    var selfImageData:Data?
    
    @IBOutlet weak var sellerProfilePic: UIImageView!
    @IBOutlet weak var ratingValueLabel: UILabel!
    @IBOutlet weak var ratingPeopleSum: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var ratingStackView: RatingControl!

    var sellerEmail = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
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
                        self.selfImageData = data!
                    }
                }
            }
        })
        
        ref.child("users").child(self.sellerID!).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value:NSDictionary? = snapshot.value as? NSDictionary

            let email:String = value?["email"] as? String ?? ""
            let description:String = value?["description"] as? String ?? ""

            let profilePic = value?["profilePicture"] as? String ?? ""
            if profilePic.hasPrefix("gs://") {
                Storage.storage().reference(forURL: profilePic).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.sellerImageData = data!
                        self.sellerProfilePic.image = UIImage.init(data: data!)
                    }
                }
            }
            
            self.sellerEmail = email.lowercased()
            self.usernameLabel.text = email.lowercased()
            self.userDescription.text = description.capitalized
            self.ratingStackView.delegate = self
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRating()
    }
    func loadRating(){
        ratingPerson = 0
        ratingNumber = 0
        ratingPerson = 0
        ref.child("user_rating").child(self.sellerID!).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value:NSDictionary? = snapshot.value as? NSDictionary
            if let value1 = value as? [String:NSDictionary]{
                
                for (key,value) in value1{
                    if key == self.userID{
                        self.ratingStackView.rating = value["rating"] as! Int
                    }
                    
                    if value["rating"] as! Int != 0{
                        self.ratingNumber += value["rating"] as! Int
                        self.ratingPerson += 1
                        self.ratingValue = Double(self.ratingNumber)/Double(self.ratingPerson)
                    }
                }
                
                self.ratingValueLabel.text = "\(self.ratingValue)"
                self.ratingPeopleSum.text = "(\(self.ratingPerson) rating)"
            }
            //            //self.ratingStackView.rating = Int(round(self.ratingValue))
        }){
            (error) in
            print(error.localizedDescription)
        }
    }

    func ratingPicker(_ picker: RatingControl, didPick rating: Int) {
        var array:[String:Int] = ["rating":rating]
        let submiTimeInterval:Int = Int(submitDate.timeIntervalSince1970)
        
        array["submitDate"] = submiTimeInterval

        ref.child("user_rating/\(sellerID!)/\(userID!)").updateChildValues(array)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAllRating"{
            let ratingVC:ReviewRatingViewController = segue.destination as! ReviewRatingViewController
            ratingVC.sellerID = sellerID
        }else if segue.identifier == "writeAReview"{
            let destination:UINavigationController = segue.destination as! UINavigationController
            let writeRatingVC:WriteReviewViewController = destination.topViewController as! WriteReviewViewController
            writeRatingVC.sellerID = sellerID
            writeRatingVC.delegate = self
        }else if segue.identifier == "sendAMessage"{
            let messageVC = segue.destination as! ChatDetailViewController
            messageVC.otherSideUserID = sellerID
            messageVC.title = sellerEmail
            messageVC.otherSideProfileImage = sellerImageData
            messageVC.selfProfileImage = selfImageData
            print(sellerID)
        }
    }
    
    func refreshTableView() {
        tableView.reloadData()
    }
    
}
