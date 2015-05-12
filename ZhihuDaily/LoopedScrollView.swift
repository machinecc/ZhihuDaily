//
//  LoopedScrollView.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/8.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class LoopedScrollView: UIScrollView {
    
    var leftImageView, middleImageView, rightImageView : UIImageView!
    var leftImageViewFrame, middleImageViewFrame, rightImageViewFrame : CGRect!
    
    var currentImage = 0
    
    var width : CGFloat = 0.0
    
    var height : CGFloat = 0.0
    
    var numImages = 0
    
    var imageUrls : [String]!
    
    var imageViews : [UIImageView] = []

    
    func initWithImageUrls(imageUrls : [String]) {
        
        self.imageUrls = imageUrls
        //self.imageUrls = ["img0", "img1", "img2", "img3", "img4"]
        //self.imageUrls = ["img0", "img1"]
        self.numImages = self.imageUrls.count
        
        self.width = self.frame.width
        self.height = self.frame.height
        
        self.contentSize = CGSizeMake(CGFloat(self.width * 3), self.height)
        self.contentOffset = CGPointMake(self.width, 0)
        self.pagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false

        
        self.leftImageViewFrame = CGRectMake(0, 0, width, height)
        self.middleImageViewFrame = CGRectMake(width, 0, width, height)
        self.rightImageViewFrame = CGRectMake(width * 2, 0, width, height)
        
        /*
        for url in self.imageUrls {
            let imageView = UIImageView(image: UIImage(named: url)!)
            self.imageViews.append(imageView)
        }
        */
        
        
        
        
        for url in imageUrls {
            let imageView = UIImageViewAsync(frame: CGRectMake(CGFloat(0), CGFloat(0), width, height))
            imageView.loadImageFromUrl(url)
            
            self.imageViews.append(imageView)
        }
        
        self.updateImageViews(true)
    }
    
    
    // When the scroll View has ended decelerating the scrolling movement, update Views
    func updateScrollView() {
        // If id == 0, scroll view was moved right;
        // If id == 1, scroll view was not moved;
        // If id == 2, scroll view was moved left.
        let id = Int(self.contentOffset.x / self.width)
        
        var leftImage, rightImage : Int
        
        if id == 0 {
            rightImage = currentImage
            currentImage = (currentImage - 1 + numImages) % numImages
            leftImage = (currentImage - 1 + numImages) % numImages
        }
        else if id == 1 {
            return
        }
        else if id == 2 {
            let leftImage = currentImage
            currentImage = (currentImage + 1) % numImages
            let rightImage = (currentImage + 1) % numImages
        }
        
        
        self.updateImageViews(false)
        
        self.contentOffset = CGPointMake(self.width, 0)
    }
    
    
    
    private func updateImageViews(isFirstTime : Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            if isFirstTime == false {
                self.leftImageView.removeFromSuperview()
                self.middleImageView.removeFromSuperview()
                self.rightImageView.removeFromSuperview()
            }
        
            self.leftImageView = self.imageViews[(self.currentImage - 1 + self.numImages) % self.numImages]
            self.leftImageView.frame = self.leftImageViewFrame
            self.addSubview(self.leftImageView)

        
            self.middleImageView = self.imageViews[self.currentImage]
            self.middleImageView.frame = self.middleImageViewFrame
            self.addSubview(self.middleImageView)

        
            self.rightImageView = self.imageViews[(self.currentImage + 1) % self.numImages]
            self.rightImageView.frame = self.rightImageViewFrame
            self.addSubview(self.rightImageView)
        }
    }
}
