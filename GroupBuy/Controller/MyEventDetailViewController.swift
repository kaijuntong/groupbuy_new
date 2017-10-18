//
//  MyEventDetailViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 18/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class MyEventDetailViewController: UITableViewController {
 
    var eventID:String!
    var countryName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = countryName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewItem"{
            let controller = segue.destination as! UINavigationController
            let itemVC = controller.topViewController as! ItemViewController
            itemVC.eventID = eventID
        }
    }
}
