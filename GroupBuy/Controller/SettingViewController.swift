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
    var ref:DatabaseReference!
    var userID:String?
    @IBOutlet weak var profilePicImageView: UIImageView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setting"
        ref = Database.database().reference()
        userID =  Auth.auth().currentUser?.uid

        ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            let value:NSDictionary? = snapshot.value as? NSDictionary
            let profilePic = value?["profilePicture"] as? String ?? ""
            if profilePic.hasPrefix("gs://") {
                Storage.storage().reference(forURL: profilePic).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profilePicImageView.image = UIImage.init(data: data!)
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //logout Action
        if indexPath.section == 3{
            let firebaseAuth:Auth = Auth.auth()
            do{
                try firebaseAuth.signOut()
                let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let loginVC:LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")as! LoginViewController
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = loginVC
                
            }catch let signOutError as NSError{
                print ("Error signing out: %@", signOutError)
            }
            
        }
    }
}
