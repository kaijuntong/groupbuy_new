//
//  LoginViewController.swift
//  
//
//  Created by KaiJun Tong on 15/10/2017.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInBtnClicked(_ sender: UIButton) {
        if let email = self.emailTextField.text, let password = self.passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password){
                (user,error) in
                if let error = error {
                    let alertController:UIAlertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
            
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController:UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarController
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func testing(_ sender: Any) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController:UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
}
