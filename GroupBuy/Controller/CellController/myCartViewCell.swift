//
//  myCartViewCell.swift
//  
//
//  Created by KaiJun Tong on 26/10/2017.
//

import UIKit
import Firebase

protocol MyCartViewCellDelegate:NSObjectProtocol {
  //  func updateTableView()
    func updateFooterView(quantity:Double,row:Int)
    func removeRow(row:Int)
}

class MyCartViewCell: UITableViewCell {
    weak var delegate: MyCartViewCellDelegate?
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var myrow:Int!
    var addPrice:Double = 0.0
    var originalQuantity:Double = 0.0
    
    var ref:DatabaseReference = Database.database().reference()
    let userID:String? = Auth.auth().currentUser?.uid
    
    var selfObject:Cart!
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        if sender.value > originalQuantity{
            addPrice += selfObject.itemPrice
        }else{
            addPrice -= selfObject.itemPrice
        }
        
        //quantityLabel.text = Int(sender.value).description
        
        ref.child("cart_item").child(userID!).child("\(selfObject.itemKey)/quantity").setValue(Int(sender.value))
        
        delegate?.updateFooterView(quantity: sender.value, row:myrow)
    }
    
    @IBAction func removeBtnClicked(_ sender: UIButton) {
        ref.child("cart_item").child(userID!).child("\(selfObject.itemKey)").removeValue()
        //delegate?.updateTableView()
        delegate?.removeRow(row: myrow)
    }
    
    func setStepperValue(num:Int){
        originalQuantity = Double(num)
        stepper.value = Double(num)
    }
}
