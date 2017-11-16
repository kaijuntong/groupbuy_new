//
//  ChatDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 15/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class ChatDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var ref:DatabaseReference!
    var userID:String? = Auth.auth().currentUser?.uid
    var firstTime = false
    var chatItemArray = [ChatItem]()
    
    var postID = ""
    var chatID:String?
    var selfProfileImage:Data?
    var otherSideProfileImage:Data?

    var otherSideUserID: String!
    var imageNeedToUpload: Data?
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        print("UserID \(userID!)")
        print("OppDI \(otherSideUserID!)")
        ref.child("chatPerson/\(userID!)").queryOrdered(byChild: "with").queryEqual(toValue: otherSideUserID!).observeSingleEvent(of: .value, with: {(snapshot) in
            let a = snapshot.value as? [String:AnyObject]

            if a == nil{
                self.firstTime = true
                let postRef:DatabaseReference = self.ref.child("chat").childByAutoId()
                let chatConnectionData = [self.userID! : self.otherSideUserID]
                postRef.setValue(chatConnectionData)

                self.postID = postRef.key
                self.configureDatabase()
            }else{
                self.ref.child("chat").queryOrdered(byChild: self.userID!).queryEqual(toValue: self.otherSideUserID).observeSingleEvent(of: .value, with: {(snapshot) in
                    let a = snapshot.value as? [String:AnyObject]
                    
                    if a == nil{
                        self.ref.child("chat").queryOrdered(byChild: self.otherSideUserID).queryEqual(toValue: self.userID!).observeSingleEvent(of: .value, with: {(snapshot1) in
                            
                            let b = snapshot1.value as? [String:AnyObject]
                            for (key,_) in b!{
                                self.postID = key
                            }
                            self.configureDatabase()

                        })
                    }else{
                        for (key,_) in a!{
                            self.postID = key
                            self.configureDatabase()
                        }
                    }

                })
            }
        })
        
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        tableView.tableFooterView = UIView(frame:.zero)
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        
        var cellNib:UINib = UINib(nibName: "chatFromCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "chatFromCell")
        
        cellNib = UINib(nibName: "chatToCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "chatToCell")
        
        cellNib = UINib(nibName: "chatPhotoToCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "chatPhotoToCell")
        
        cellNib = UINib(nibName: "chatPhotoFromCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "chatPhotoFromCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatDetailViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatDetailViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.estimatedRowHeight = 44.0
        
//        let iPath = NSIndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
//        self.tableView.scrollToRow(at: iPath as IndexPath,
//                                   at: UITableViewScrollPosition.bottom,
//                                              animated: true)
//

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatItemArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //from 自己 send
        let messageItem = chatItemArray[indexPath.row]
        
        //自己send
        if messageItem.from as! String == "\(userID!)"{
            if messageItem.photo != nil{
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatPhotoToCell", for: indexPath)
                cell.backgroundColor = UIColor.clear
                
                let profileImageView = cell.viewWithTag(100) as! UIImageView
                
                if let selfProfileImage = selfProfileImage{
                    profileImageView.image = UIImage.init(data: selfProfileImage)
                }
                
                let chatImageLabel = cell.viewWithTag(101) as! UIImageView
                chatImageLabel.image = UIImage.init(data: messageItem.photo!)
                
                let dateLabel = cell.viewWithTag(102) as! UILabel
                 dateLabel.text = displayTimestamp(ts: messageItem.date)
                return cell
            }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatToCell", for: indexPath)
            cell.backgroundColor = UIColor.clear

            let profileImageView = cell.viewWithTag(100) as! UIImageView

            if let selfProfileImage = selfProfileImage{
                profileImageView.image = UIImage.init(data: selfProfileImage)
            }
            
            let msg = cell.viewWithTag(101) as! UILabel
            let dateLabel = cell.viewWithTag(102) as! UILabel
            
            msg.text = messageItem.message as! String
            dateLabel.text = displayTimestamp(ts: messageItem.date)
                return cell
                
            }
        }else{//别人的对话
            if messageItem.photo != nil{
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatPhotoFromCell", for: indexPath)
                cell.backgroundColor = UIColor.clear
                
                let profileImageView = cell.viewWithTag(100) as! UIImageView
                
                if let otherSideProfileImage = otherSideProfileImage{
                    profileImageView.image = UIImage.init(data: otherSideProfileImage)
                }
                
                let chatImageLabel = cell.viewWithTag(101) as! UIImageView
                chatImageLabel.image = UIImage.init(data: messageItem.photo!)
                
                let dateLabel = cell.viewWithTag(102) as! UILabel
                dateLabel.text = displayTimestamp(ts: messageItem.date)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatFromCell", for: indexPath)
                cell.backgroundColor = UIColor.clear
                
                let profileImageView = cell.viewWithTag(100) as! UIImageView
                
                if let otherSideProfileImage = otherSideProfileImage{
                    profileImageView.image = UIImage.init(data: otherSideProfileImage)
                }
                
                let msg = cell.viewWithTag(101) as! UILabel
                let dateLabel = cell.viewWithTag(102) as! UILabel
                
                msg.text = messageItem.message as! String
                dateLabel.text = displayTimestamp(ts: messageItem.date)
                return cell
                
            }
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "chatFromCell", for: indexPath)
//            cell.backgroundColor = UIColor.clear
//
//            let profileImageView = cell.viewWithTag(100) as! UIImageView
//
//            if let otherSideProfileImage = otherSideProfileImage{
//                profileImageView.image = UIImage.init(data: otherSideProfileImage)
//            }
//
//            let msg = cell.viewWithTag(101) as! UILabel
//            let dateLabel = cell.viewWithTag(102) as! UILabel
//
//            msg.text = messageItem.message as! String
//            dateLabel.text = displayTimestamp(ts: messageItem.date)
//            return cell
        }
    }

    @objc func keyboardWillShow(notification:NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @IBAction func sendBtn(_ sender: UIButton) {
        if firstTime{
            self.tableView.reloadData()
        }
        messageTextField.resignFirstResponder()
        let message = messageTextField.text
        messageTextField.text = ""
        if message != ""{
            if firstTime{
                ref.child("chatPerson").child("\(userID!)").child("\(postID)/with").setValue("\(otherSideUserID!)")
                ref.child("chatPerson").child("\(otherSideUserID!)").child("\(postID)/with").setValue("\(userID!)")
            }
            
            let submitDate:Int = Int(Date.init().timeIntervalSince1970)
            let messageData = ["message":message, "from":userID!,"date":submitDate] as [String : Any]
            
            ref.child("chat/\(postID)/last_message").setValue(message)
            ref.child("chat/\(postID)/date").setValue(submitDate)
            ref.child("chatMessage/\(postID)").childByAutoId().setValue(messageData)
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func configureDatabase(){
        print(postID)
        print("This is post ID")
        ref.child("chatMessage/\(postID)").observe(.childAdded, with: {(snapshot) in
         
            let value = snapshot.value as? [String:AnyObject]
            print(value)
            print("-asd-adas-d-")
            if let value = value{
                
                let from = value["from"] as! String
                let date = value["date"] as! Double

                if let photo = value["photo"] as? String{
                    if photo.hasPrefix("gs://") {
                        Storage.storage().reference(forURL: photo).getData(maxSize: INT64_MAX) {(data, error) in
                            if let error = error {
                                print("Error downloading: \(error)")
                                return
                            }
                            DispatchQueue.main.async {
                                let chatItem = ChatItem.init(from: from, photo: data!, date: date)
                                self.chatItemArray.append(chatItem)
                                self.chatItemArray.sort{$0 < $1}
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                }else{
                    let message = value["message"] as! String
                    let chatItem = ChatItem.init(from: from, message: message, date: date)
                    self.chatItemArray.append(chatItem)
                    self.chatItemArray.sort{$0 < $1}
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func displayTimestamp(ts: Double) -> String {
        let date:Date = Date(timeIntervalSince1970: ts)
        let formatter:DateFormatter = DateFormatter()
        //formatter.timeZone = NSTimeZone.system
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        //check camerabutton is availabe
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func ImageBtnClick(_ sender: UIButton) {
        pickAnImage(UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func cameraBtnClicked(_ sender: UIButton) {
        pickAnImage(UIImagePickerControllerSourceType.camera)
    }
    
    func pickAnImage(_ sourceType:UIImagePickerControllerSourceType){
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //imagepicjer delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(selectedImage, 0.0){
    
            self.imageNeedToUpload = imageData
            uploadImageToFirebaseStorage(data: imageData)

            dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadImageToFirebaseStorage(data: Data){
            let storageRef:StorageReference = Storage.storage().reference()
            let imagePath:String = "chat_image/" + postID + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            
            let uploadMetadata:StorageMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            let uploadTask:StorageUploadTask = storageRef.child(imagePath).putData(data, metadata: uploadMetadata){
                (metadata, error) in
                if (error != nil){
                    print("I received an error! \(error?.localizedDescription)")
                }else{
                    if self.firstTime{
                        self.tableView.reloadData()
                    }
                    
                        if self.firstTime{
                            self.ref.child("chatPerson").child("\(self.userID!)").child("\(self.postID)/with").setValue("\(self.otherSideUserID!)")
                            self.ref.child("chatPerson").child("\(self.otherSideUserID!)").child("\(self.postID)/with").setValue("\(self.userID!)")
                        }
                        
                        let submitDate:Int = Int(Date.init().timeIntervalSince1970)
                        let messageData = ["photo":storageRef.child((metadata?.path)!).description, "from":self.userID!,"date":submitDate] as [String : Any]
                    
                        
                        self.ref.child("chat/\(self.postID)/date").setValue(submitDate)
                        self.self.ref.child("chatMessage/\(self.postID)").childByAutoId().setValue(messageData)
                    
                    
                }
            }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
