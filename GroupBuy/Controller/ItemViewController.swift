//
//  ItemViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 16/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class ItemViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var itemimageView: UIImageView!
    @IBOutlet weak var productTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NEW ITEM"
        
        self.tableView.separatorStyle = .none
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func crossBtnClicked(_ sender: UIButton) {
        itemimageView.image = UIImage(named: "photoalbum")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print("HEL222222O")
        if indexPath.row == 0{
            print("HELLO")
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
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            itemimageView.image = selectedImage
            itemimageView.contentMode = .scaleAspectFill
            itemimageView.clipsToBounds = true
        }
        
        let leadingConstraint = NSLayoutConstraint(item: itemimageView, attribute: .leading, relatedBy: .equal, toItem: itemimageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
         let trailingConstraint = NSLayoutConstraint(item: itemimageView, attribute: .trailing, relatedBy: .equal, toItem: itemimageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
         let topConstraint = NSLayoutConstraint(item: itemimageView, attribute: .top, relatedBy: .equal, toItem: itemimageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
         let bottomConstraint = NSLayoutConstraint(item: itemimageView, attribute: .bottom, relatedBy: .equal, toItem: itemimageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
