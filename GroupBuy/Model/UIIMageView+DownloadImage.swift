//
//  UIIMageView+DownloadImage.swift
//  StoreSearch
//
//  Created by KaiJun Tong on 11/09/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit

extension UIImageView{
    func loadImage(url:URL) -> URLSessionDownloadTask{
        let session = URLSession.shared
        
        //1
        let downloadTask = session.downloadTask(with: url, completionHandler: {
            [weak self] url, response, error in
            //2
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data){
                //3
                DispatchQueue.main.async {
                    if let strongSelf = self{
                        strongSelf.image = image
                    }
                }
            }
        })
        
        //4
        downloadTask.resume()
        return downloadTask
    }
}
