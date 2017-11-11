//
//  PaymentTableViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 06/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree
import Firebase

class PaymentTableViewController: UITableViewController {
    var cartArray:[Cart]!
    var totalPrice: Double!
    let userID:String? = Auth.auth().currentUser?.uid
    var submitDate:Date = Date()
    var ref:DatabaseReference!
    
    var deliveryAddress:String = ""
    
    @IBOutlet weak var deliveryAddressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        priceLabel.text = "RM \(totalPrice!)"
        getAddress()
    }

    let toKinizationKey:String = "sandbox_qd7bxfd3_dqtd4cp5nkbqp69p"
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var payButton: UIButton!
//        {
//        didSet {
//            payButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -42, bottom: 0, right: 0)
//            payButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
//            payButton.layer.cornerRadius = payButton.bounds.midY
//            payButton.layer.masksToBounds = true
//        }
//    }
    
    @IBOutlet weak var currencyLabel: UILabel! {
        didSet {
            currencyLabel.layer.cornerRadius = currencyLabel.bounds.midY
            currencyLabel.layer.masksToBounds = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //amountTextField.becomeFirstResponder()
    }
    
    
    @IBAction func pay(_ sender: Any) {
        // Test Values
        // Card Number: 4111111111111111
        // Expiration: 08/2018
        
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: toKinizationKey, request: request)
        { [unowned self] (controller, result, error) in
            
            if let error = error {
                self.show(message: error.localizedDescription)
                
            } else if (result?.isCancelled == true) {
                self.show(message: "Transaction Cancelled")
                
            } //else if let nonce = result?.paymentMethod?.nonce, let amount = self.amountTextField.text {
                else if let nonce = result?.paymentMethod?.nonce{
                //self.sendRequestPaymentToServer(nonce: nonce, amount: amount)
                self.sendRequestPaymentToServer(nonce: nonce, amount: "\(self.totalPrice!)")
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: String) {
        activityIndicator.startAnimating()
        
        let paymentURL = URL(string: "http://untempered-points.000webhostapp.com/donate/donate/pay.php")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)".data(using: String.Encoding.utf8)
        print(request)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let data = data else {
                self?.show(message: error!.localizedDescription)
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
                self?.show(message: "Transaction failed. Please try again.")
                return
            }
            //print(result)
            self?.submitToFirebase()
            self?.show(message: "Successfully charged. Thanks So Much :)")
            
            }.resume()
    }
    
    func show(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func submitToFirebase(){
        var dataToInsert = [String:Any]()
        
        let submiTimeInterval = Int(submitDate.timeIntervalSince1970)
        
        dataToInsert["buyer_id"] = userID!
        dataToInsert["order_date"] = submiTimeInterval
        dataToInsert["paymentPrice"] = totalPrice
        
        var itemArray = [String:Any]()
        
        var purchaserCheckListArray = [String:Any]()
        
        for i in cartArray{
            var item = [String:Any]()
            item["itemPrice"] = i.itemPrice
            item["itemName"] = i.itemName
            item["itemQuantity"] = i.itemQuantity
            item["itemCurrentStatus"] = 0
            
            itemArray[i.itemKey] = item
            
            //let dataArray = ["\(userID!)": i.itemQuantity] as [String : Any]
            
            ref.child("purchasing_list").child("\(i.eventKey)").child("\(i.itemKey)/buyer_info/\(userID!)").setValue(i.itemQuantity)
            ref.child("customer_list").child("\(i.eventKey)").child("\(userID!)/item_info/\(i.itemKey)").setValue(i.itemQuantity)
        }
        
        dataToInsert["orderItems"] = itemArray
        dataToInsert["deliveryAddress"] = deliveryAddress
        ref.child("orderlist").childByAutoId().setValue(dataToInsert)
        
        ref.child("cart_item").child("\(userID!)").setValue("")
        dismiss(animated: true, completion: nil)
    }
    
    func getAddress(){
        ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value = snapshot.value as? NSDictionary

            let firstname = value?["firstname"] as? String ?? ""
            let lastname = value?["lastname"] as? String ?? ""
            let address1 = value?["address1"] as? String ?? ""
            let address2 = value?["address2"] as? String ?? ""
            let city = value?["city"] as? String ?? ""
            let country = value?["country"] as? String ?? ""
            let postcode = value?["postcode"] as? String ?? ""
            //let phone = value?["phone"] as? String ?? ""
            
            let addressString = """
            \(firstname) \(lastname)
            \(address1),\(address2)
            \(postcode), \(city) \(country)
            """
            self.deliveryAddress = addressString
            self.deliveryAddressLabel.text = addressString
        }){
            (error) in
            print(error.localizedDescription)
        }
        
    }
    
}
