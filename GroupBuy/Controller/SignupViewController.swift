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
        print("TEsaaaaaaat")

        if let email = self.emailTextField.text, let password = passwordTextField.text, password == confirmPasswordTextField.text{
            print("TEst")
            Auth.auth().createUser(withEmail: email, password:password){
                (user,error) in
                if let error = error {
                    return
                }
                //Login
                Auth.auth().signIn(withEmail: email, password: password){
                    (user,error) in
                    if let error = error {
                        return
                    }
                    
                    self.view.endEditing(true)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController
                }

            }
        }
    }
    
    @IBAction func signInBtnClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
