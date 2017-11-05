//
//  myCartViewCell.swift
//  
//
//  Created by KaiJun Tong on 26/10/2017.
//

import UIKit
import Firebase

protocol MyCartViewCellDelegate:NSObjectProtocol {
    func updateTableView()
}

class MyCartViewCell: UITableViewCell {
    weak var delegate: MyCartViewCellDelegate?
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    var selfObject:Cart!
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        quantityLabel.text = Int(sender.value).description
        
        ref.child("cart_item").child(userID!).child("\(selfObject.itemKey)/quantity").setValue(Int(sender.value))
    }
    
    @IBAction func removeBtnClicked(_ sender: UIButton) {
        ref.child("cart_item").child(userID!).child("\(selfObject.itemKey)").removeValue()
        delegate?.updateTableView()
    }
    func setStepperValue(num:Int){
        stepper.value = Double(num)
    }
}
