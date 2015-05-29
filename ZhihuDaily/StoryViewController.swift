//
//  StoryViewController.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/20.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class StoryViewController: UIViewController {
    
    var storyID : String!
    
    var storyDetail : StoryDetail!

    var topImageView: UIImageViewAsync!

    //var homeViewController : HomeViewController!
    
    
    
    @IBOutlet var webView: UIWebView!

    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 隐藏NavigationBar
        self.navigationController?.navigationBarHidden = true

        
        // 设置webview相关属性
        self.webView.scrollView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        self.webView.scrollView.showsHorizontalScrollIndicator = false
        // 将topImageView添加为webView的subview
        self.topImageView = UIImageViewAsync(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        self.topImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.topImageView.clipsToBounds = true
        self.webView.scrollView.addSubview(self.topImageView)
        
        
        // 设置toolbar的相关属性，toolbar的高度为30
        self.toolbar.translucent = true
    }
    
    
    
    func initViews() {
        let nsurl = NSURL(string: Consts.StoryUrl + storyID)
        let urlRequest = NSMutableURLRequest(URL: nsurl!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = "GET"
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response : NSURLResponse!, data:NSData!, error: NSError!) -> Void in
            
            var jsonerror : NSError?
            
            let jsonObject : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonerror)
            
            if jsonerror == nil {
                let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                //println(jsonString)
                
                if let storyDetail = StoryDetail.initWithJsonData(jsonObject) {

                    
                    self.storyDetail = storyDetail
                    
                    
                    // 更新topImageView
                    if storyDetail.isOnHomePage() == true {
                        self.topImageView.loadImageFromUrl(storyDetail.image)
                    }
                    
                    
                    let body : String = "<link href='\(storyDetail.css[0])' rel='stylesheet' type='text/css' /><div style='text-align:justify'>\(storyDetail.body)</div>"

                    self.webView.loadHTMLString(body, baseURL: nil)


                    // 在主线程中更新UI
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        // 更新webView
                        //println(storyDetail.body)
                        
                        //println(222)
                    })
                    

                }
                else {
                    NSLog("Parsing latest stories failed")
                }
            }
            else {
                NSLog("Parsing latest stories failed")
            }
        }

    }
    
    // 返回首页
    @IBAction func onBackButtonClicked(sender: UIBarButtonItem) {        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    // 直接切换至下一篇文章的视图
    @IBAction func onNextButtonClicked(sender: UIBarButtonItem) {
        // 获取stack中的HomeViewController
        let homeVC = self.navigationController?.viewControllers.first as? HomeViewController
        assert(homeVC != nil, "Root view controller is not HomeViewController")
        
        // 判断是否已到达已下载的最后一篇文章，若不是，则浏览下一篇文章
        if let indexPath = homeVC?.indexPathForNextStory() {
            let story = homeVC!.storyAtIndexPath(indexPath)
            homeVC?.indexPathOfCurrentStory = indexPath
            
            // 创建一个新的StoryViewController,并
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextStoryVC = storyboard.instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
            nextStoryVC.storyID = story.id
            nextStoryVC.initViews()

        
            let transition : CATransition = CATransition()
            transition.duration = 0.15
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromTop
            
            self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
            self.navigationController!.pushViewController(nextStoryVC, animated: false)
            
        }
    }
    
}
