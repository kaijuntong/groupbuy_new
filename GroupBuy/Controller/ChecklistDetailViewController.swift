//
//  ChecklistDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 09/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ChecklistDetailViewController: UITableViewController {

    var ref:DatabaseReference!
    var itemID:String!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        title = "My Purchasing List"

        
        configureDatabase()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureDatabase(){
        ref.child("eventItems").child("\(itemID!)").observeSingleEvent(of: .value, with:{
            (snapshot) in
            let a = snapshot.value as? [String:AnyObject] ?? [:]
            print(a)
            
            self.productLabel.text = a["itemName"] as! String
            self.descriptionLabel.text = a["itemDescription"] as! String
            self.priceLabel.text = "\(a["itemPrice"] as! Double)"
            self.sizeLabel.text = a["itemSize"] as! String
            
            let imageURL = a["itemImage"] as! String
            
            if imageURL.hasPrefix("gs://") {
                Storage.storage().reference(forURL:imageURL).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.productImageView.image = UIImage.init(data: data!)
                    }
                }
            }
            
        })

    }

    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
