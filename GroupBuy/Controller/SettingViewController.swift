//
//  SettingViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setting"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //logout Action
        if indexPath.section == 3{
            let firebaseAuth = Auth.auth()
            do{
                try firebaseAuth.signOut()
                let storyboard = UIStoryboard(name:"Main", bundle:nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = loginVC
                
            }catch let signOutError as NSError{
                print ("Error signing out: %@", signOutError)
            }
            
        }
    }
}
