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
    
    var leftImageView, middleImageView, rightImageView : UIImageViewAsync!
    var leftImageViewFrame, middleImageViewFrame, rightImageViewFrame : CGRect!
    
    var currentImage = 0
    
    var width : CGFloat = 0.0
    
    var height : CGFloat = 0.0
    
    var numImages = 0
    
    var imageUrls : [String]!
    
    var imageViews : [UIImageViewAsync] = []

    
    func initWithImageUrls(imageUrls : [String]) {
        self.imageUrls = imageUrls
        self.numImages = self.imageUrls.count
        
        self.width = self.frame.width
        self.height = self.frame.height
        
        self.leftImageViewFrame = CGRectMake(0, 0, width, height)
        self.middleImageViewFrame = CGRectMake(width, 0, width, height)
        self.rightImageViewFrame = CGRectMake(width * 2, 0, width, height)
        
        for url in imageUrls {
            let imageView = UIImageViewAsync(frame: CGRectMake(CGFloat(0), CGFloat(0), width, height))
            imageView.loadImageFromUrl(url)
            
            self.imageViews.append(imageView)
        }
        

        self.updateImageViews()
        self.addSubview(self.leftImageView)
        self.addSubview(self.middleImageView)
        self.addSubview(self.rightImageView)
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
        
        self.contentOffset = CGPointMake(self.width, 0)
        
        self.updateImageViews()
    }
    
    
    
    private func updateImageViews() {
        self.leftImageView = imageViews[(currentImage - 1 + numImages) % numImages]
        self.leftImageView.frame = self.leftImageViewFrame
        
        self.middleImageView = imageViews[currentImage]
        self.middleImageView.frame = self.middleImageViewFrame
        
        self.rightImageView = imageViews[(currentImage + 1) % numImages]
        self.rightImageView.frame = self.rightImageViewFrame
    }
}
