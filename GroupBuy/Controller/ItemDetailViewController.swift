//
//  ItemDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 10/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ItemDetailViewController: UITableViewController {
    var ref:DatabaseReference!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sellerEmail: UILabel!
    
    var item :CountryItems!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if item.productImage.hasPrefix("gs://") {
            Storage.storage().reference(forURL: item.productImage).getData(maxSize: INT64_MAX) {(data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    self.productImageView.image = UIImage.init(data: data!)
                }
            }
        }


        productLabel.text = item.itemName
        priceLabel.text = "\(item.itemPrice)"
        sizeLabel.text = "250 ml"
        
        ref = Database.database().reference()
        ref.child("users").child(self.item.sellerID).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value = snapshot.value as? NSDictionary
            print(value)
            let email = value?["email"] as? String ?? ""
            
            self.sellerEmail.text = email
        }){
            (error) in
            print(error.localizedDescription)
        }
        

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0{
            addToCart()
            
            let alertController = UIAlertController(title: "Done", message: "Succescul added to cart", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func addToCart(){
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            var cartItem = [String:Any]()

            cartItem["item_id"] = item.itemKey
            cartItem["quantity"] = 1
//
            ref.child("cart_item").child(uid).childByAutoId().setValue(cartItem)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserDetail"{
            let controller = segue.destination as! SellerDetailViewController
            controller.sellerID = item.sellerID
            print(item.sellerID)
        }
    }
    
    
}
