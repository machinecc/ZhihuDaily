//
//  InfiniteScrollView.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/17.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit


class InfiniteScrollView: UIScrollView, UIScrollViewDelegate {
    
    var imageViews : [UIImageView] = []
    var imagesCount : Int = 0
    
    var width : CGFloat = 0.0
    var height : CGFloat = 0.0
    
    
    
    func initWithImageUrls(imageUrls : [String]) {
        assert(imageUrls.count > 0, "ImageUrls cannot be empty")
        
        self.imagesCount = imageUrls.count
        self.width = self.frame.width
        self.height = self.frame.height
        println("\(self.width)    \(self.height)")
        
        self.delegate = self
        self.contentSize = CGSizeMake(CGFloat(Float(width) * Float(imagesCount + 2)), height)
        self.contentOffset = CGPointMake(self.width, 0)
        self.pagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false

        
        var lastImgUrl = imageUrls.last!
        var firstImgUrl = imageUrls.first!
        //imageUrls.insert(lastImgUrl, atIndex: 0)
        //imageUrls.append(firstImgUrl)

        //for (index, url) in
        
        /*
        for (index, url) in enumerate(imageUrls) {
            let imgframe = CGRectMake(CGFloat(Float(width) * Float(index + 1)), CGFloat(0), width, height)
            
            //let imgView = UIImageViewAsync(frame: imgframe)
            //imgView.loadImageFromUrl(url)
            
            let imgView = UIImageView(frame: imgframe)
            imgView.image = UIImage(named: url)
            
            self.imageViews.append(imgView)
        }
        
        var firstview = self.imageViews.last!
        var lastview = self.imageViews.first!
        
        firstview.frame = CGRectMake(CGFloat(0), CGFloat(0), width, height)
        lastview.frame = CGRectMake(CGFloat(Float(width) * Float(imagesCount + 1)), CGFloat(0), width, height)
        
        self.imageViews.insert(firstview, atIndex: 0)
        self.imageViews.append(lastview)
        
        
        dispatch_async(dispatch_get_main_queue()) {
            for imgView in self.imageViews {
                self.addSubview(imgView)
            }
        }
*/
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        dispatch_async(dispatch_get_main_queue()) {
            let id = Int(self.contentOffset.x / self.width)
        
            if id == 0 {
                self.scrollRectToVisible(CGRectMake(CGFloat(Float(self.width) * Float(self.imagesCount)), 0.0, self.width, self.height), animated: false)
            }
            else if id == self.imagesCount + 1 {
                self.scrollRectToVisible(CGRectMake(self.width * 1.0, 0.0, self.width, self.height), animated: false)
            }
        }
    }
    
    
}
