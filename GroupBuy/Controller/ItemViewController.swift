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

    @IBOutlet weak var itemimageView: UIImageView!
    @IBOutlet weak var productTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextField!
    
    var ref:DatabaseReference!
    let userID:String? = Auth.auth().currentUser?.uid
    
    var eventDetail:[String:Any]!
    
    var eventID:String!
    var imageData:Data?
    var hasModifiedImage:Bool = false
    
    var itemToEdit:Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NEW ITEM"
        ref = Database.database().reference()
        self.tableView.separatorStyle = .none
        
        if let item = itemToEdit{
            title = "Edit Item"
            productTextField.text = item.itemName
            priceTextField.text = "\(item.price)"
            sizeTextField.text = item.size
            descriptionTextView.text = item.description
            
            if item.imageLoc.hasPrefix("gs://") {
                Storage.storage().reference(forURL: item.imageLoc).getData(maxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.imageData = data!
                        self.itemimageView.image = UIImage.init(data: data!)
                    }
                }
            }
        }
        
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
        if indexPath.section == 1 && indexPath.row == 0{
            let alertController:UIAlertController = UIAlertController(title: "Alert", message: "Are your sure want to delete this item?", preferredStyle: .alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
                (actionSheetController) -> Void in
                print("Deleting Item")
                
                self.ref.child("eventItems").child(self.itemToEdit!.itemKey).removeValue()
                
                
                
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            tableView.deselectRow(at: indexPath, animated: true)
            present(alertController, animated: true, completion: nil)
        }
        
        if indexPath.row == 0{
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker:UIImagePickerController = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: nil)
            }
        }
        
    }
    //imagepicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(selectedImage, 0.0){
            itemimageView.image = selectedImage
            itemimageView.contentMode = .scaleAspectFill
            itemimageView.clipsToBounds = true
            
            self.hasModifiedImage = true
            self.imageData = imageData
            dismiss(animated: true, completion: nil)
        }
        
        let leadingConstraint:NSLayoutConstraint = NSLayoutConstraint(item: itemimageView, attribute: .leading, relatedBy: .equal, toItem: itemimageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint:NSLayoutConstraint = NSLayoutConstraint(item: itemimageView, attribute: .trailing, relatedBy: .equal, toItem: itemimageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint:NSLayoutConstraint = NSLayoutConstraint(item: itemimageView, attribute: .top, relatedBy: .equal, toItem: itemimageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint:NSLayoutConstraint = NSLayoutConstraint(item: itemimageView, attribute: .bottom, relatedBy: .equal, toItem: itemimageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
    }
    
    func uploadImageToFirebaseStorage(data: Data){
        if !hasModifiedImage{
            self.sendMessage(data: ["itemImage": (itemToEdit?.imageLoc)!])
        }else{
            let storageRef:StorageReference = Storage.storage().reference()
            let imagePath:String = "item_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            
            let uploadMetadata:StorageMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            let uploadTask:StorageUploadTask = storageRef.child(imagePath).putData(data, metadata: uploadMetadata){
                (metadata, error) in
                if (error != nil){
                    print("I received an error! \(error?.localizedDescription)")
                }else{
                    print("Upload complete! Here's some metadata! \(metadata)")
                    //                print("\(metadata!.downloadURL())")
                    
                    // use sendMessage to add imageURL to database
                    self.sendMessage(data: ["itemImage": storageRef.child((metadata?.path)!).description])
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendMessage(data: [String:Any]) {
        print("test3")
        var eventItemInfo:[String:Any] = data
        //insert into databas
            eventItemInfo["uid"] = userID
            eventItemInfo["itemName"] = productTextField.text
        let num:String = priceTextField.text!
        let doubleNum:Double? = Double(num)
            eventItemInfo["itemPrice"] = doubleNum
            eventItemInfo["itemSize"] = sizeTextField.text
            eventItemInfo["itemDescription"] = descriptionTextView.text
            eventItemInfo["event_id"] = eventID
        
        //event_id1
        let countryName:String = eventDetail["destination"] as! String
        let startDate:Double = eventDetail["departdate"] as! Double
        let dueDate:Double = eventDetail["returndate"] as! Double
        
        eventItemInfo["event_id1"] = [
            "departdate": startDate,
            "returndate": dueDate,
            "destination": countryName
        ]
        
        if let item = itemToEdit{
            ref.child("eventItems").child(item.itemKey).setValue(eventItemInfo)
        }else{
            ref.child("eventItems").childByAutoId().setValue(eventItemInfo)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let item = itemToEdit{
            return 2
        }else{
            return 1
        }
    }
    
}
