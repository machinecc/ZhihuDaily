//
//  LoopedScrollView.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/8.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class LoopedScrollView: UIScrollView, UIScrollViewDelegate {
    
    var leftImageView, middleImageView, rightImageView : UIImageView!
    var leftImageViewFrame, middleImageViewFrame, rightImageViewFrame : CGRect!
    
    var currentImage = 0
    
    var width : CGFloat = 0.0
    
    var height : CGFloat = 0.0
    
    var numImages = 0
    
    var imageUrls : [String]!
    
    var imageViews : [UIImageView] = []
    
    var pageControl : UIPageControl!

    
    func initWithFrameAndImageUrls(frame : CGRect, imageUrls : [String]) {
        self.frame = frame
        self.width = self.frame.width
        self.height = self.frame.height
        
        self.imageUrls = imageUrls
        self.numImages = self.imageUrls.count

        
        self.contentSize = CGSizeMake(CGFloat(self.width * 3), self.height)
        self.contentOffset = CGPointMake(self.width, 0)
        self.pagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.delegate = self
        self.layer.zPosition = 1
    
        
        // 设置PageControl相关属性
        self.pageControl = UIPageControl(frame: CGRectMake(0 + 100, 200, 800, 20))
        self.pageControl.backgroundColor = UIColor.redColor()
        self.addSubview(self.pageControl)

        self.pageControl.layer.zPosition = 100
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor.grayColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.redColor()
        self.pageControl.enabled = true
        

        self.leftImageViewFrame = CGRectMake(0, 0, width, height)
        self.middleImageViewFrame = CGRectMake(width, 0, width, height)
        self.rightImageViewFrame = CGRectMake(width * 2, 0, width, height)
        
        for url in imageUrls {
            let imageView = UIImageViewAsync(frame: CGRectMake(CGFloat(0), CGFloat(0), width, height))
            imageView.loadImageFromUrl(url)
            //let imageView = UIImageView(frame: CGRectMake(CGFloat(0), CGFloat(0), width, height))
            //imageView.image = UIImage(named: url)
            imageView.layer.zPosition = 1
            
            self.imageViews.append(imageView)
        }
        
        self.updateImageViews(true)
    }

    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updateScrollView()
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
        
    }
    
    
    
    private func updateImageViews(isFirstTime : Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            if isFirstTime == false {
                self.leftImageView.removeFromSuperview()
                self.middleImageView.removeFromSuperview()
                self.rightImageView.removeFromSuperview()
            }
            else {
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
            
            self.scrollRectToVisible(CGRectMake(self.width, 0, self.width, self.height), animated: false)
            self.pageControl.currentPage = self.currentImage
        }
    }
}
