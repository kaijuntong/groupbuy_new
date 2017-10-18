//
//  ItemViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 16/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ItemViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var itemimageView: UIImageView!
    @IBOutlet weak var productTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    
    var eventID:String!
    var imageData:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NEW ITEM"
        
        self.tableView.separatorStyle = .none
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        
        uploadImageToFirebaseStorage(data: imageData!)
        dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func crossBtnClicked(_ sender: UIButton) {
        itemimageView.image = UIImage(named: "photoalbum")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    //imagepicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(selectedImage, 0.5){
            itemimageView.image = selectedImage
            itemimageView.contentMode = .scaleAspectFill
            itemimageView.clipsToBounds = true
            
            self.imageData = imageData
            dismiss(animated: true, completion: nil)
        }
        
        let leadingConstraint = NSLayoutConstraint(item: itemimageView, attribute: .leading, relatedBy: .equal, toItem: itemimageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
         let trailingConstraint = NSLayoutConstraint(item: itemimageView, attribute: .trailing, relatedBy: .equal, toItem: itemimageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
         let topConstraint = NSLayoutConstraint(item: itemimageView, attribute: .top, relatedBy: .equal, toItem: itemimageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
         let bottomConstraint = NSLayoutConstraint(item: itemimageView, attribute: .bottom, relatedBy: .equal, toItem: itemimageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
    }
    
    func uploadImageToFirebaseStorage(data: Data){
        let storageRef = Storage.storage().reference()
        let imagePath = "chat_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
      
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let uploadTask = storageRef.child(imagePath).putData(data, metadata: uploadMetadata){
            (metadata, error) in
            if (error != nil){
                print("I received an error! \(error?.localizedDescription)")
            }else{
//                print("Upload complete! Here's some metadata! \(metadata)")
//                print("\(metadata!.downloadURL())")
                
                // use sendMessage to add imageURL to database
                self.sendMessage(data: ["itemImage": storageRef.child((metadata?.path)!).description])
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func sendMessage(data: [String:String]) {
        var eventItemInfo = data
        //insert into database
            var ref:DatabaseReference!
            let userID = Auth.auth().currentUser?.uid
            
            ref = Database.database().reference()
        
            eventItemInfo["user_id"] = userID
            eventItemInfo["itemName"] = productTextField.text
            eventItemInfo["itemPrice"] = priceTextField.text
            eventItemInfo["itemSize"] = sizeTextField.text
            eventItemInfo["itemdescription"] = descriptionTextView.text
            eventItemInfo["event_id"] = eventID
        
            ref.child("eventItems").childByAutoId().setValue(eventItemInfo)
            
    }
}
