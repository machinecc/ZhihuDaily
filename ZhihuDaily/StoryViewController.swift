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

    
    
    @IBOutlet var webView: UIWebView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.scrollView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        
        self.navigationController?.navigationBarHidden = true
        
        //self.topImageView.frame = CGRectMake(0, 0, self.view.frame.width, 180)
        self.topImageView = UIImageViewAsync(frame: CGRectMake(0, 0, self.view.frame.width, 200))
        self.topImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.topImageView.clipsToBounds = true
        
        self.webView.scrollView.addSubview(self.topImageView)
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
    

    
    
}
