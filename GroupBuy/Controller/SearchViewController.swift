//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by KaiJun Tong on 09/09/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var searchBstorar2:UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    var hasSearched:Bool = false
    var searchResults = [CountryItems]()
    var isLoading:Bool = false
    
    var ref:DatabaseReference!
    var userID:String? =  Auth.auth().currentUser?.uid
    //用来cancel operation
    var dataTask:URLSessionDataTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view, typically from a nib.
        //Add margin
        tableView.contentInset = UIEdgeInsets(top:108, left:0, bottom:0, right:0)
        
        var cellNib:UINib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        
        searchBar.becomeFirstResponder()
    }
    
    
    //parse Dictionary
    func parse(dictionary: [String:AnyObject]) -> [CountryItems]{
        
        for(key,value) in dictionary{
            let abc:[String:AnyObject] = value as![String:AnyObject]
            
            let itemName:String = abc["itemName"] as! String
            let itemSize:String = abc["itemSize"] as! String
            let itemDescription:String = abc["itemDescription"] as! String
            let itemPrice:Double = abc["itemPrice"] as! Double
            let itemImage:String = abc["itemImage"] as! String
            let sellerID:String = abc["uid"] as! String
            let eventIdInfo = abc["event_id1"] as! [String:AnyObject]
            
            let startDate:Double = eventIdInfo["departdate"] as! Double
            let dueDate:Double = eventIdInfo["returndate"] as! Double
            
            let searchResult:CountryItems = CountryItems(itemKey: key, username: "", itemName: itemName, itemPrice: itemPrice, itemSaleQuantity: 0, productImage: itemImage, sellerID: sellerID, itemDescription:itemDescription, itemSize:itemSize,startDate:startDate,dueDate:dueDate)
            
            searchResults.append(searchResult)
        }
        
        return searchResults
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
}


extension SearchViewController:UISearchBarDelegate{
    //自己原本的func
    func searchBarSearchButtonClicked(_ searchbar: UISearchBar){
        performSearch()
    }
    
    func performSearch() {
        //print("searach text is '\(searchBar.text!)'")
        
        searchBar.resignFirstResponder()
        searchResults = []
        
        //cancel operation
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()
        
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            
            hasSearched = true
            searchResults = []
            
            
            let escapedSearchText:String = searchBar.text!.lowercased()
                //.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!.lowercased()
            
            print(escapedSearchText)
            ref.child("eventItems").queryOrdered(byChild: "itemName").queryStarting(atValue: "\(escapedSearchText)").queryEnding(atValue: "\(escapedSearchText)"+"\u{f8ff}").observeSingleEvent(of: .value, with: {
                (snapshot) in
                print("-----------------")
                let a = snapshot.value as? [String:AnyObject] ?? [:]
                
                self.searchResults = self.parse(dictionary: a)
                self.searchResults.sort{ $0 < $1 }

                self.isLoading = false
                self.tableView.reloadData()
            }){
                (error) in
                print(error.localizedDescription)
                self.hasSearched = false
                self.isLoading = false
                self.tableView.reloadData()
                self.showNetworkError()
            }
            
        }
    }
    
    //直接把 search bar 的color 弄去 status bar，这样子 status bar就不会是白色
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func showNetworkError(){
        let alert:UIAlertController = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Stores.Please try again.", preferredStyle: .alert)
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading{
            //loading
          return 1
        }else if !hasSearched{
            return 0
        }else if searchResults.count == 0{
            //not found
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading{
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner:UIActivityIndicatorView = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }else if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for:indexPath)
        }else{
            let cell:SearchResultCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult:CountryItems = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
        
    }
    
    
}

extension SearchViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasSearched{
            performSegue(withIdentifier: "showItemDetail", sender: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        }else{
            return indexPath
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetail"{
            if let indexPath:IndexPath = tableView.indexPathForSelectedRow{
                print("!2313123")
                let destinationController:ItemDetailViewController = segue.destination as! ItemDetailViewController
                destinationController.item = searchResults[indexPath.row]
                print(searchResults[indexPath.row].itemName)
                print(searchResults[indexPath.row].productImage)
            }
        }
    }
}
