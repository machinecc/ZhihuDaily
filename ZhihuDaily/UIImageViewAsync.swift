//
//  UIImageViewAsync.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/6.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit


class UIImageViewAsync: UIImageView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    
    private func downloadDataFromUrl(url : String, completion : ((data : NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
    
    func loadImageFromUrl(url : String) {
        self.downloadDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode = UIViewContentMode.ScaleToFill
                self.image = UIImage(data: data!)
            }
        }
    }
    
}