//
//  ArticlesListViewController.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/4.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class StroiesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    
    
    @IBOutlet weak var topStoriesScrollView: UIScrollView!
    
    @IBOutlet weak var storiesListTableView: UITableView!
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    
    var topStoryImageWidth = 320
    var topStoryImageHeight = 140
    
    
    // 文章集合，按日期分类
    var dailyStories = [NSDate:[Story]]()
    
    // 所有文章的日期，按降序排列
    var dates = [NSDate]()

    // Slide页展示的Top Stories
    var topStories = [Story]()
    
    
    var dateFormatter = NSDateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 设置日期格式
        self.dateFormatter.dateFormat = "yyyymmdd"
        
        // 设置tableView相关属性
        self.storiesListTableView.dataSource = self
        self.storiesListTableView.delegate = self
        
        // 设置ScrollView相关属性
        self.topStoriesScrollView.delegate = self
        self.topStoriesScrollView.pagingEnabled = true
        self.topStoriesScrollView.showsVerticalScrollIndicator = false
        self.topStoriesScrollView.showsHorizontalScrollIndicator = false
        self.topStoriesScrollView.bounces = false
        
        // 设置ScrollView中图片大小
        var screenBounds = UIScreen.mainScreen().bounds
        self.topStoryImageWidth = Int(screenBounds.size.width)
        self.topStoryImageHeight = Int(screenBounds.size.height / 3)
        
        // 设置ScrollView视图
        //self.topStoriesScrollView.frame.size = CGSizeMake(CGFloat(self.topStoryImageWidth), CGFloat(self.topStoryImageHeight))
        self.topStoriesScrollView.frame = CGRectMake(CGFloat(0), CGFloat(0), CGFloat(self.topStoryImageWidth), CGFloat(self.topStoryImageHeight))
        self.topStoriesScrollView.backgroundColor = UIColor.blueColor()
        
        
        // 下载最新文章
        self.downloadLatestStories()
    }
    
    
    
    
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dates.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section < self.dates.count, "No stories in section \(section)")
        let date = self.dates[section]
        
        assert(self.dailyStories[date] != nil, "Story not found on day \(date)")
        return self.dailyStories[date]!.count
    }
    
    
    
    // 获取文章简介的单元格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.storiesListTableView.dequeueReusableCellWithIdentifier(Consts.StoryDescriptionCellID) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Consts.StoryDescriptionCellID)
        }
        
        let date = self.dates[indexPath.section]

        let story = self.dailyStories[date]![indexPath.row]
        
        cell?.textLabel?.text = story.title
        
        return cell!
    }
    

    
    
    
    
    
    // 下载最新文章,并初始化文章列表和Top Stories
    func downloadLatestStories() {
        let nsurl = NSURL(string: Consts.LatestStoriesUrl)
        let urlRequest = NSMutableURLRequest(URL: nsurl!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = "GET"
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response : NSURLResponse!, data:NSData!, error: NSError!) -> Void in
            
            //println(111)
            var jsonerror : NSError?
            
            let jsonObject : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonerror)
            
            //println(222)

            if jsonerror == nil {
                if let dic = jsonObject as? NSDictionary {
                    // 格式化日期
                    let dateStr = dic["date"] as! String
                    let date : NSDate  = self.dateFormatter.dateFromString(dateStr)!

                
                    var rawStories = dic.objectForKey("stories") as! NSArray
                    var rawTopStories = dic.objectForKey("top_stories") as! NSArray
                    
                    
                    // 将新下载的文章加入字典，并维护当前所有已下载文章的日期列表
                    self.dailyStories[date] = self.parseStories(rawStories)
                    self.dates.append(date)
                    self.dates.sort({ (lop : NSDate, rop : NSDate) -> Bool in
                        if lop.compare(rop) == NSComparisonResult.OrderedDescending {
                            return true
                        }
                        else {
                            return false
                        }
                    })
                    
                    // 更新文章列表视图
                    self.storiesListTableView.reloadData()
                    
                    
                    
                    // 更新Top Stories
                    self.topStories = self.parseStories(rawTopStories)
                    
                    
                    // 设置ScrollView视图
                    self.topStoriesScrollView.contentSize = CGSizeMake(CGFloat(self.topStoryImageWidth * self.topStories.count), CGFloat(self.topStoryImageHeight))
                    
                    
                    

                    // 更新ScrollView图片
                    for (index, topStory) in enumerate(self.topStories) {
                        var imgView = UIImageViewAsync(frame: CGRectMake(CGFloat(self.topStoryImageWidth * index), CGFloat(0), CGFloat(self.topStoryImageWidth), CGFloat(self.topStoryImageHeight)))
                        
                        if topStory.imageUrl != nil {
                            //imgView.setImageFromUrl(topStory.imageUrl!)
                            //imgView.image = UIImage(named: "img\(index % 3)")
                            imgView.image = UIImage(named: "img1")
                        }

                        self.topStoriesScrollView.addSubview(imgView)
                    }
                    
                    
                    
                    
                    // 设置pagecontrol
                    self.pageControl.numberOfPages = self.topStories.count
                    self.pageControl.currentPage = 0
                    
                    

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
    
    
    
    // 解析文章内容，以Story的格式存储
    func parseStories(rawStories : NSArray) -> [Story] {
        var stories : [Story] = []
        
        for storyObj in rawStories {
            let title = storyObj.objectForKey("title") as! String
            
            let id = (storyObj.objectForKey("id") as! NSNumber).stringValue
            
            let imageUrls = storyObj.objectForKey("images") as? NSArray
            
            var imageUrl : String = ""
            
            if imageUrls != nil {
                imageUrl = imageUrls!.objectAtIndex(0) as! String
            }
            
            let story = Story(title: title, id: id, imageUrl: imageUrl)
            
            stories.append(story)
        }
        return stories
    }
    
    

    // TopStoriesScrollView的delegate方法
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.topStoriesScrollView {
            
        }
    }
    

    
    
    
}