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
    @IBOutlet weak var sellerProfilePic: UIImageView!
    
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


        productLabel.text = item.itemName.capitalized
        priceLabel.text = "\(item.itemPrice)"
        sizeLabel.text = "\(item.itemSize)".capitalized
        descriptionLabel.text = "\(item.itemDescription)".capitalized
        
        ref = Database.database().reference()
        ref.child("users").child(self.item.sellerID).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value:NSDictionary? = snapshot.value as? NSDictionary
            print(value)
            let email:String = value?["email"] as? String ?? ""
            
            let profilePic = value?["profilePicture"] as? String ?? ""
            if profilePic.hasPrefix("gs://") {
                Storage.storage().reference(forURL: profilePic).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.sellerProfilePic.image = UIImage.init(data: data!)
                    }
                }
            }
            
            self.sellerEmail.text = email.lowercased()
        }){
            (error) in
            print(error.localizedDescription)
        }
        

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0{
            addToCart()
            
            let alertController:UIAlertController = UIAlertController(title: "Done", message: "Succescul added to cart", preferredStyle: .alert)
            let okAction:UIAlertAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func addToCart(){
        ref = Database.database().reference()
        let user:User? = Auth.auth().currentUser
        if let user = user {
            let uid:String = user.uid
            var cartItem:[String:Any] = [String:Any]()

            //cartItem["item_id"] = item.itemKey
            cartItem["quantity"] = 1
//
            //ref.child("cart_item").child(uid).childByAutoId().setValue(cartItem)
            ref.child("cart_item").child(uid).child("\(item.itemKey)").setValue(cartItem)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserDetail"{
            print(item.sellerID)
            print(item.sellerID)
            print(item.sellerID)

            let controller:SellerDetailViewController = segue.destination as! SellerDetailViewController
            controller.sellerID = item.sellerID
            print(item.sellerID)
        }
    }
    
    
}
