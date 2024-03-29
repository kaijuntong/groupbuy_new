//
//  MyProfileViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 16/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase
class MyProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var address1TextField: UITextField!
    @IBOutlet weak var address2TextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var hasModifiedImage = false
    var ref:DatabaseReference!
    var imageData:Data?

    let userID:String? = Auth.auth().currentUser?.uid
    let email:String? = Auth.auth().currentUser?.email
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        emailTextField.isEnabled = false
        
        ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            //get user value
            let value:NSDictionary? = snapshot.value as? NSDictionary
            let username:String = value?["username"] as? String ?? ""
            let description:String = value?["description"] as? String ?? ""
            let firstname:String = value?["firstname"] as? String ?? ""
            let lastname:String = value?["lastname"] as? String ?? ""
            let address1:String = value?["address1"] as? String ?? ""
            let address2:String = value?["address2"] as? String ?? ""
            let city:String = value?["city"] as? String ?? ""
            let country:String = value?["country"] as? String ?? ""
            let postcode:String = value?["postcode"] as? String ?? ""
            let picURL:String = value?["picURL"] as? String ?? ""
            let phone:String = value?["phone"] as? String ?? ""
            
            let profilePic = value?["profilePicture"] as? String ?? ""
            
            
            if profilePic.hasPrefix("gs://") {
                Storage.storage().reference(forURL: profilePic).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profilePic.image = UIImage.init(data: data!)
                    }
                }
            }

            
//            if let userImage = Auth.auth().currentUser?.photoURL{
//                if let imageData = try? Data(contentsOf: userImage){
//                    self.profilePic.image = UIImage(data: imageData)
//                }
//            }
            
           // self.usernameTextField.text = username
            self.emailTextField.text = self.email
            self.descriptionTextField.text = description
            self.firstNameTextField.text = firstname
            self.lastNameTextField.text = lastname
            self.address1TextField.text = address1
            self.address2TextField.text = address2
            self.postcodeTextField.text = postcode
            self.cityTextField.text = city
            self.countryTextField.text = country
            self.phoneTextField.text = phone
        }){
            (error) in
            print(error.localizedDescription)
        }
    }
    @IBAction func updateProfilePicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnClicked(_ sender: UIBarButtonItem) {
        uploadImageToFirebaseStorage(data: imageData!)
        
        let user:[String:String?] = ["email":self.email,
                    "description": descriptionTextField.text?.uppercased(),
                    "firstname":firstNameTextField.text?.uppercased(),
                    "lastname":lastNameTextField.text?.uppercased(),
                    "address1":address1TextField.text?.uppercased(),
                    "address2":address2TextField.text?.uppercased(),
                    "city":cityTextField.text?.uppercased(),
                    "country":countryTextField.text?.uppercased(),
                    "postcode":postcodeTextField.text?.uppercased(),
                    "phone":phoneTextField.text?.uppercased()
        ]
        
        let childUpdated:[String:[String:String?]] = ["/users/\(userID!)": user]
        ref.updateChildValues(childUpdated)
        dismiss(animated: true, completion: nil)
    }
    
    //imagepicjer delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(selectedImage, 0.0){
            profilePic.image = selectedImage
            profilePic.contentMode = .scaleToFill
            profilePic.clipsToBounds = true
            
            self.imageData = imageData
            hasModifiedImage = true
            dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadImageToFirebaseStorage(data: Data){
        if !hasModifiedImage{
            //self.sendMessage(data: ["itemImage": (itemToEdit?.imageLoc)!])
            return
        }else{
            let storageRef:StorageReference = Storage.storage().reference()
            let imagePath:String = "profile_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"

            let uploadMetadata:StorageMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            let uploadTask:StorageUploadTask = storageRef.child(imagePath).putData(data, metadata: uploadMetadata){
                (metadata, error) in
                if (error != nil){
                    print("I received an error! \(error?.localizedDescription)")
                }else{
                    //self.sendMessage(data: ["profilePicture": storageRef.child((metadata?.path)!).description])
                    self.ref.child("users/\(self.userID!)/profilePicture").setValue(storageRef.child((metadata?.path)!).description)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
