//
//  SellerDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 26/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class SellerDetailViewController: UITableViewController {
    var ref:DatabaseReference!
    var sellerID: String!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("-000000000\(sellerID)")
        ref = Database.database().reference()
        ref.child("users").child(self.sellerID!).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value = snapshot.value as? NSDictionary
            print(value)
            let email = value?["email"] as? String ?? ""
            let description = value?["description"] as? String ?? ""
            
            self.usernameLabel.text = email
            self.userDescription.text = description
        }){
            (error) in
            print(error.localizedDescription)
        }
    }

}
