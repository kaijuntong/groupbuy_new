//
//  PasswordTableViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 12/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase
class PasswordTableViewController: UITableViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnClicked(_ sender: UIBarButtonItem) {
        let currentPassword = currentPasswordTextField.text
        let newPassword = newPasswordTextField.text
        let verifyPassword = verifyPasswordTextField.text
        
        if let currentPassword = currentPassword, let newPassword = newPassword, let verifyPassword = verifyPassword {
           
            if currentPassword == ""{
                alert(title:"Alert",msg: "Current password cannot be empty")
                return
            }
            if newPassword != verifyPassword{
                alert(title:"Alert", msg: "New password must same as verify password")
                return
            }
            
            let user = Auth.auth().currentUser!
                
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
                
            user.reauthenticate(with: credential, completion: {(error) in
                if error != nil{
                        self.alert(title:"Alert", msg: "Current Password is incorrect")
                    }else{
                        user.updatePassword(to: verifyPassword)
                        self.alert(title:"Success", msg: "Successful update password")
                        self.currentPasswordTextField.text = ""
                        self.newPasswordTextField.text = ""
                        self.verifyPasswordTextField.text = ""
                    }
                })
        }else{
            alert(title:"Alert" ,msg: "You must fill in all the information")
        }
    }
    
    func alert(title:String,msg:String){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
