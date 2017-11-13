//
//  SignupViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase
class SignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUpBtnClicked(_ sender: UIButton) {
        
        if emailTextField.text == ""{
            let alertController:UIAlertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }else if let email = self.emailTextField.text, let password = passwordTextField.text, password == confirmPasswordTextField.text{
            
            Auth.auth().createUser(withEmail: email, password:password){
                (user,error) in
                if let error = error {
                    let alertController:UIAlertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAlert:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAlert)
                    
                    self.present(alertController,animated: true, completion: nil)
                    return
                }
                //Login
                Auth.auth().signIn(withEmail: email, password: password){
                    (user,error) in
                    if let error = error {
                        return
                    }
                    
                    self.view.endEditing(true)
                    let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController:UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController
                }

            }
        }else{
            let alertController:UIAlertController = UIAlertController(title: "Error", message: "Password not match, Please try again.", preferredStyle: .alert)
            
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func signInBtnClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
