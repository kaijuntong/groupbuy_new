//
//  HomeViewController.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 05/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView:UICollectionView!
    @IBOutlet var hottestItemsCollectionView:UICollectionView!
    @IBOutlet var sellerCollectionView:UICollectionView!
    
    private var countries:[Country] = [Country.init(countryName: "USA", countryImage: UIImage(named: "usa")),
                                       Country.init(countryName: "Taiwan", countryImage: UIImage(named: "taiwan")),
                                       Country.init(countryName: "Korea", countryImage: UIImage(named: "korea")),
                                       Country.init(countryName: "Australia", countryImage: UIImage(named: "australia")),
                                       ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView{
            return countries.count
        }else{
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountriesCell", for: indexPath) as! CountryCollectionViewCell
            
            // Configure the cell
            cell.countryName.text = countries[indexPath.row].countryName
            cell.countryImage.image = countries[indexPath.row].countryImage
            
            //apply round corner
            cell.layer.cornerRadius = 4.0
            return cell
        }
        else if collectionView == self.hottestItemsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemsCell", for: indexPath)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SellerCell", for: indexPath)
            let imageview = cell.viewWithTag(20) as! UIImageView
            imageview.layer.cornerRadius = 40
            imageview.clipsToBounds = true
            return cell
        }
        
    }

}

