//
//  CustomerMakeSecondPaymentViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 23/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase
import Braintree
import BraintreeDropIn

class CustomerMakeSecondPaymentViewController: UIViewController {
    var orderID:String?
    var sellerID:String?
    
    var totalPrice: String?
    let userID:String? = Auth.auth().currentUser?.uid
    
    var ref:DatabaseReference!
    
    
    @IBOutlet weak var deliveryAddressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let email:String? = Auth.auth().currentUser?.email
    
    var deliveryAddress:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("-----")
        print(orderID)
        print(sellerID)
        ref = Database.database().reference()
        //tableView.tableFooterView = UIView(frame: CGRect.zero)


        ref.child("secondPayment/\(sellerID!)/\(orderID!)").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? [String:String] ?? [:]

            self.totalPrice = value["price"] ?? "0"
            self.priceLabel.text = "RM \(self.totalPrice!)"

            print("------")
            print(self.totalPrice!)
        })
        
        activityIndicator.isHidden = true
    }
    
    let toKinizationKey:String = "sandbox_qd7bxfd3_dqtd4cp5nkbqp69p"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var payButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                self.sendRequestPaymentToServer(nonce: nonce, amount: self.totalPrice!)
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
            //self?.show(message: "Successfully charged. Thanks So Much :)"
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                let alertController = UIAlertController(title: "Success", message: "Successfully charged. Thanks So Much.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in self?.navigationController?.popViewController(animated: true)}))
                self?.present(alertController, animated: true, completion: nil)
            }
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
        ref.child("secondPayment/\(sellerID!)/\(orderID!)/paidStatus").setValue("2")
    }
}
