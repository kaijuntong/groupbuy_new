//
//  MyOrderDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 13/11/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class MyOrderDetailViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var cellNib:UINib = UINib(nibName: "TitleCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "TitleCell")
        
        cellNib = UINib(nibName: "AddressCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "AddressCell")
        
        cellNib = UINib(nibName: "SummaryCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SummaryCell")
        
        tableView.estimatedRowHeight  = 44
        tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
              return tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
        }else if indexPath.row == 1{
             return  tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
        }else if indexPath.row == 2{
              return tableView.dequeueReusableCell(withIdentifier: "SummaryCell", for: indexPath)
        }else{
            return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        }
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 88
        }else if indexPath.row == 1{
            return 88
        }else if indexPath.row == 2{
            return 60
        }else{
            return 44
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
