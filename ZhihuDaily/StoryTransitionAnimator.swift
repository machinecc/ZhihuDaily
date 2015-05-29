//
//  StoryTransitionAnimator.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/29.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class StoryTransitionAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    weak var transitionContext : UIViewControllerContextTransitioning?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        
    }
    
    
}