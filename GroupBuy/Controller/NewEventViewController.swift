//
//  NewEventViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 10/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class NewEventViewController: UITableViewController,UITextFieldDelegate {
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var saveBarButton:UIBarButtonItem!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var doneBarButton:UIBarButtonItem!
    @IBOutlet var startDatePickerCell: UITableViewCell!
    @IBOutlet var dueDatePickerCell: UITableViewCell!
    
    @IBOutlet weak var startDatePicker:UIDatePicker!
    @IBOutlet weak var dueDatePicker:UIDatePicker!

    var startDate:Date = Date()
    var dueDate:Date = Date()
    
    var startDatePickerVisible:Bool = false
    var dueDatePickerVisible:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDatePicker.minimumDate = startDate
    
        dueDatePicker.minimumDate = startDate + 1
    
        updateStartDateLabel()
        updateDueDateLabel()
        
    }
    
    @IBAction func cancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(){
        var ref:DatabaseReference!
        let userID:String? = Auth.auth().currentUser?.uid
        
        ref = Database.database().reference()
        
        let startTimeInterval:Int = Int(startDate.timeIntervalSince1970)
        let dueTimeInterval:Int = Int(dueDate.timeIntervalSince1970)
        
        let eventInfo:[String:Any] = ["uid":userID!,
                         "destination":textField.text ?? "",
                         "departdate": startTimeInterval,
                         "returndate": dueTimeInterval]
        
        ref.child("events").childByAutoId().setValue(eventInfo)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 0{
            return indexPath
        }else{
            return nil
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText:NSString = textField.text! as NSString
        
        let newText:NSString = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        
        return true
    }
    
    func updateStartDateLabel(){
        let formatter:DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        startDateLabel.text = formatter.string(from: startDate)
    }
    
    func updateDueDateLabel(){
        let formatter:DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    func showStartDatePicker(){
        hideDueDatePicker()
        textField.resignFirstResponder()
        
        startDatePickerVisible = true
        
        let indexPathDateRow:IndexPath = IndexPath(row: 0, section: 1)
        let indexPathDatePicker:IndexPath = IndexPath(row: 1, section: 1)
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow){
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        
        startDatePicker.setDate(startDate, animated:false)
    }
    
    func hideStartDatePicker(){
        if startDatePickerVisible{
            startDatePickerVisible = false
            
            let indexPathDateRow:IndexPath = IndexPath(row: 0, section: 1)
            let indexPathDatePicker:IndexPath = IndexPath(row: 1, section: 1)
            
            if let cell = tableView.cellForRow(at: indexPathDateRow){
                cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            tableView.endUpdates()
        }
    }

    func showDueDatePicker(){
        hideStartDatePicker()
        textField.resignFirstResponder()
        
        dueDatePickerVisible = true
        
        let indexPathDateRow:IndexPath = IndexPath(row: 0, section: 2)
        let indexPathDatePicker:IndexPath = IndexPath(row: 1, section: 2)
        
        if let dateCell = tableView.cellForRow(at: indexPathDateRow){
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        
        dueDatePicker.setDate(dueDate, animated:false)
    }
    
    func hideDueDatePicker(){
        if dueDatePickerVisible{
            dueDatePickerVisible = false
            
            let indexPathDateRow:IndexPath = IndexPath(row: 0, section: 2)
            let indexPathDatePicker:IndexPath = IndexPath(row: 1, section: 2)
            
            if let cell = tableView.cellForRow(at: indexPathDateRow){
                cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1 && startDatePickerVisible) || (section == 2 && dueDatePickerVisible){
            return 2
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 1{
            return startDatePickerCell
        }else if indexPath.section == 2 && indexPath.row == 1{
            return dueDatePickerCell
        }else{
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 1{
            return 217
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 0{
            if !startDatePickerVisible{
                showStartDatePicker()
            }else{
                hideStartDatePicker()
            }
        }
        if indexPath.section == 2 && indexPath.row == 0{
            if !dueDatePickerVisible{
                showDueDatePicker()
            }else{
                hideDueDatePicker()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath:IndexPath = indexPath
        if (indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 1{
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    @IBAction func startDateChanged(_ datePicker: UIDatePicker){
        startDate = datePicker.date
        updateStartDateLabel()
    }
    
    @IBAction func dueDateChanged(_ datePicker: UIDatePicker){
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideStartDatePicker()
        hideDueDatePicker()
    }
}
