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

class PaymentTableViewController: UIViewController {
    var cartArray:[Cart]!
    var totalPrice: Double!
    let userID:String? = Auth.auth().currentUser?.uid
    var submitDate:Date = Date()
    var ref:DatabaseReference!
    
    
    @IBOutlet weak var deliveryAddressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let email:String? = Auth.auth().currentUser?.email
    
    var deliveryAddress:String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        for i in cartArray{
            print(i)
            print("=------=")
        }
        ref = Database.database().reference()
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        priceLabel.text = "RM \(totalPrice!)"
        getAddress()
        activityIndicator.isHidden = true
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
        activityIndicator.isHidden = false
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
            self?.dismiss(animated: true, completion: nil)
            }.resume()
    }
    
    func show(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func submitToFirebase(){
        var dataToInsert:[String:Any] = [String:Any]()
        
        let submiTimeInterval:Int = Int(submitDate.timeIntervalSince1970)
        
        dataToInsert["buyer_id"] = userID!
        dataToInsert["order_date"] = submiTimeInterval
        dataToInsert["paymentPrice"] = totalPrice
        dataToInsert["deliveryAddress"] = deliveryAddress
        
        let postRef:DatabaseReference = ref.child("orderlist").childByAutoId()
        postRef.setValue(dataToInsert)
        
        let postID:String = postRef.key
        
        
        var itemArray:[String:Any] = [String:Any]()
        var buyerItemArray:[String:Any] = [String:Any]()
        
        //only loop 3 time if 3 item
        for i in cartArray{
            var item:[String:Any] = [String:Any]()
            
            item["itemPrice"] = i.itemPrice
            item["itemName"] = i.itemName
            item["itemQuantity"] = i.itemQuantity
            item["itemCurrentStatus"] = 0
            item["itemImage"] = i.itemImage
            item["eventKey"] = i.eventKey
            
            itemArray[i.itemKey] = item
            
            //let dataArray = ["\(userID!)": i.itemQuantity] as [String : Any]
            
            
            let itemInfoArray:[String:Any] = ["itemName":i.itemName, "itemQuantity":i.itemQuantity] as [String : Any]
            buyerItemArray[i.itemKey] = itemInfoArray
            
            let buyerInfo:[String:Any] = ["userAddress":deliveryAddress, "itemInfo":buyerItemArray, "userEmail":email!]
            
            ref.child("purchasing_list").child("\(i.eventKey)").child("\(i.itemKey)/buyer_info/\(userID!)").observeSingleEvent(of: .value, with: {(snapshot) in
                
                print(snapshot)
                
                let a = snapshot.value as? Int
                
                var oldQuantity = i.itemQuantity
                
                if let a = a{
                    oldQuantity += a
                }
                print(oldQuantity)
                self.ref.child("purchasing_list").child("\(i.eventKey)").child("\(i.itemKey)/buyer_info/\(self.userID!)").setValue(oldQuantity)
            })
            
            self.ref.child("customerlist").child("\(i.eventKey)").child("\(postID)").child("\(userID!)").setValue(buyerInfo)
        }
        ref.child("orderlist").child("\(postID)/orderItems").setValue(itemArray)
        ref.child("cart_item").child("\(userID!)").setValue("")
    }
    
    func getAddress(){
        ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value:NSDictionary? = snapshot.value as? NSDictionary
            
            let firstname:String = value?["firstname"] as? String ?? ""
            let lastname:String = value?["lastname"] as? String ?? ""
            let address1:String = value?["address1"] as? String ?? ""
            let address2:String = value?["address2"] as? String ?? ""
            let city:String = value?["city"] as? String ?? ""
            let country:String = value?["country"] as? String ?? ""
            let postcode:String = value?["postcode"] as? String ?? ""

            
            let addressString:String = """
            \(firstname) \(lastname)
            \(address1),\(address2)
            \(postcode), \(city) \(country)
            """
            
            self.deliveryAddress = addressString
            self.deliveryAddressLabel.text = addressString
            self.viewWillAppear(true)
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
}


//class PaymentTableViewController: UITableViewController {
//    var cartArray:[Cart]!
//    var totalPrice: Double!
//    let userID:String? = Auth.auth().currentUser?.uid
//    var submitDate:Date = Date()
//    var ref:DatabaseReference!
//
//    let email:String? = Auth.auth().currentUser?.email
//
//    var deliveryAddress:String = ""
//
//    @IBOutlet weak var deliveryAddressLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        for i in cartArray{
//            print(i)
//            print("=------=")
//        }
//        ref = Database.database().reference()
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        priceLabel.text = "RM \(totalPrice!)"
//        getAddress()
//    }
//
//    let toKinizationKey:String = "sandbox_qd7bxfd3_dqtd4cp5nkbqp69p"
//
//    @IBOutlet weak var amountTextField: UITextField!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var payButton: UIButton!
////        {
////        didSet {
////            payButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -42, bottom: 0, right: 0)
////            payButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
////            payButton.layer.cornerRadius = payButton.bounds.midY
////            payButton.layer.masksToBounds = true
////        }
////    }
//
//    @IBOutlet weak var currencyLabel: UILabel! {
//        didSet {
//            currencyLabel.layer.cornerRadius = currencyLabel.bounds.midY
//            currencyLabel.layer.masksToBounds = true
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        //amountTextField.becomeFirstResponder()
//    }
//
//
//    @IBAction func pay(_ sender: Any) {
//        // Test Values
//        // Card Number: 4111111111111111
//        // Expiration: 08/2018
//
//        let request =  BTDropInRequest()
//        let dropIn = BTDropInController(authorization: toKinizationKey, request: request)
//        { [unowned self] (controller, result, error) in
//
//            if let error = error {
//                self.show(message: error.localizedDescription)
//
//            } else if (result?.isCancelled == true) {
//                self.show(message: "Transaction Cancelled")
//
//            } //else if let nonce = result?.paymentMethod?.nonce, let amount = self.amountTextField.text {
//                else if let nonce = result?.paymentMethod?.nonce{
//                //self.sendRequestPaymentToServer(nonce: nonce, amount: amount)
//                self.sendRequestPaymentToServer(nonce: nonce, amount: "\(self.totalPrice!)")
//            }
//            controller.dismiss(animated: true, completion: nil)
//        }
//
//        self.present(dropIn!, animated: true, completion: nil)
//    }
//
//    func sendRequestPaymentToServer(nonce: String, amount: String) {
//        activityIndicator.startAnimating()
//
//        let paymentURL = URL(string: "http://untempered-points.000webhostapp.com/donate/donate/pay.php")!
//        var request = URLRequest(url: paymentURL)
//        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)".data(using: String.Encoding.utf8)
//        print(request)
//        request.httpMethod = "POST"
//
//        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
//            guard let data = data else {
//                self?.show(message: error!.localizedDescription)
//                return
//            }
//
//            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
//                self?.show(message: "Transaction failed. Please try again.")
//                return
//            }
//            //print(result)
//            self?.submitToFirebase()
//            self?.show(message: "Successfully charged. Thanks So Much :)")
//            self?.dismiss(animated: true, completion: nil)
//            }.resume()
//    }
//
//    func show(message: String) {
//        DispatchQueue.main.async {
//            self.activityIndicator.stopAnimating()
//
//            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//
//    func submitToFirebase(){
//        var dataToInsert:[String:Any] = [String:Any]()
//
//        let submiTimeInterval:Int = Int(submitDate.timeIntervalSince1970)
//
//        dataToInsert["buyer_id"] = userID!
//        dataToInsert["order_date"] = submiTimeInterval
//        dataToInsert["paymentPrice"] = totalPrice
//        dataToInsert["deliveryAddress"] = deliveryAddress
//
//        let postRef:DatabaseReference = ref.child("orderlist").childByAutoId()
//        postRef.setValue(dataToInsert)
//
//        let postID:String = postRef.key
//
//
//        var itemArray:[String:Any] = [String:Any]()
//        var buyerItemArray:[String:Any] = [String:Any]()
//
//        //only loop 3 time if 3 item
//        for i in cartArray{
//            var item:[String:Any] = [String:Any]()
//
//            item["itemPrice"] = i.itemPrice
//            item["itemName"] = i.itemName
//            item["itemQuantity"] = i.itemQuantity
//            item["itemCurrentStatus"] = 0
//            item["itemImage"] = i.itemImage
//            item["eventKey"] = i.eventKey
//
//            itemArray[i.itemKey] = item
//
//            //let dataArray = ["\(userID!)": i.itemQuantity] as [String : Any]
//
//
//            let itemInfoArray:[String:Any] = ["itemName":i.itemName, "itemQuantity":i.itemQuantity] as [String : Any]
//            buyerItemArray[i.itemKey] = itemInfoArray
//
//            let buyerInfo:[String:Any] = ["userAddress":deliveryAddress, "itemInfo":buyerItemArray, "userEmail":email!]
//
//            ref.child("purchasing_list").child("\(i.eventKey)").child("\(i.itemKey)/buyer_info/\(userID!)").observeSingleEvent(of: .value, with: {(snapshot) in
//
//                print(snapshot)
//
//                let a = snapshot.value as? Int
//
//                var oldQuantity = i.itemQuantity
//
//                if let a = a{
//                    oldQuantity += a
//                }
//                print(oldQuantity)
//                self.ref.child("purchasing_list").child("\(i.eventKey)").child("\(i.itemKey)/buyer_info/\(self.userID!)").setValue(oldQuantity)
//            })
//
//            self.ref.child("customerlist").child("\(i.eventKey)").child("\(postID)").child("\(userID!)").setValue(buyerInfo)
//        }
//        ref.child("orderlist").child("\(postID)/orderItems").setValue(itemArray)
//        ref.child("cart_item").child("\(userID!)").setValue("")
//    }
//
//    func getAddress(){
//        ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: {(snapshot) in
//            //get user value
//            let value:NSDictionary? = snapshot.value as? NSDictionary
//
//            let firstname:String = value?["firstname"] as? String ?? ""
//            let lastname:String = value?["lastname"] as? String ?? ""
//            let address1:String = value?["address1"] as? String ?? ""
//            let address2:String = value?["address2"] as? String ?? ""
//            let city:String = value?["city"] as? String ?? ""
//            let country:String = value?["country"] as? String ?? ""
//            let postcode:String = value?["postcode"] as? String ?? ""
//            //let phone = value?["phone"] as? String ?? ""
//
//            let addressString:String = """
//            \(firstname) \(lastname)
//            \(address1),\(address2)
//            \(postcode), \(city) \(country)
//            """
//            self.deliveryAddress = addressString
//            self.deliveryAddressLabel.text = addressString.capitalized
//        }){
//            (error) in
//            print(error.localizedDescription)
//        }
//
//    }
//
//}

