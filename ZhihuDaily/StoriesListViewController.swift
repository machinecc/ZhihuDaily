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
    
    
    @IBOutlet weak var topStoriesScrollView: LoopedScrollView!
    
    
    @IBOutlet weak var storiesListTableView: UITableView!
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var topStoryTitle: UILabel!
    
    
    
    
    var svWidth : Float = 0.0
    var svHeight : Float = 0.0
    
    
    // 文章集合，按日期分类
    var dailyStories = [Date:[Story]]()
    
    // 所有文章的日期，按降序排列
    var dates = [Date]()

    // Slide页展示的Top Stories
    var topStories = [Story]()
    
    
    var pullRefreshControl : UIRefreshControl!
    var isLoadingMoreStories : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        // 设置ScrollView相关属性
        self.topStoriesScrollView.delegate = self
        self.topStoriesScrollView.layer.zPosition = 1
        self.svWidth = Float(self.view.bounds.width)
        self.svHeight = Float(self.view.bounds.height / 3)
        //self.topStoriesScrollView.frame.size = CGSizeMake(CGFloat(self.svWidth), CGFloat(self.svHeight))
        
        
        // 设置PageControl相关属性
        self.pageControl.layer.zPosition = 100
        self.pageControl.pageIndicatorTintColor = UIColor.grayColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        self.pageControl.enabled = false
        
        // 设置Top Story Title相关属性
        self.topStoryTitle.layer.zPosition = 120
        self.topStoryTitle.textColor = UIColor.whiteColor()
        self.topStoryTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.topStoryTitle.numberOfLines = 0
        self.topStoryTitle.font = UIFont.boldSystemFontOfSize(18)
        
        
        // 设置tableView相关属性
        self.storiesListTableView.dataSource = self
        self.storiesListTableView.delegate = self
        self.storiesListTableView.showsHorizontalScrollIndicator = false
        self.storiesListTableView.showsVerticalScrollIndicator = false
        self.storiesListTableView.bounces = true
        self.storiesListTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)        
        
        // 注册tableView单元格
        let nib = UINib(nibName: "StoryDescriptionCell", bundle: nil)
        self.storiesListTableView.registerNib(nib, forCellReuseIdentifier: Consts.StoryDescriptionCellID)

        
        // 注册tableView Header单元格
        //self.storiesListTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: Consts.StoriesHeaderCellID)
        
        
        // 设置下拉刷新控件
        self.pullRefreshControl = UIRefreshControl()
        self.pullRefreshControl.attributedTitle = NSAttributedString(string: "正在更新内容")
        self.pullRefreshControl.addTarget(self, action: "pullDownRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.storiesListTableView.addSubview(self.pullRefreshControl)
    
        
        // 下载最新文章
        self.downloadLatestStories()
    }
    
    
    // 下拉更新文章
    func pullDownRefresh(sender : AnyObject) {
        self.downloadLatestStories()
    }
    
    // 上拉storiesListTableView，载入更多文章
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isEqual(self.storiesListTableView) {
            if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height {
                if self.isLoadingMoreStories == false {
                    self.isLoadingMoreStories = true
                    self.loadMoreStories()
                }
            }
        }
    }
    
    
    // 下载更多文章
    func loadMoreStories() {
        // 获取已下载过文章的最早的日期
        let earliestDate = self.dates.last!
        
        let nsurl = NSURL(string: Consts.PreviousStoriesUrl + earliestDate.toString("yyyyMMdd"))
        let urlRequest = NSMutableURLRequest(URL: nsurl!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = "GET"
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response : NSURLResponse!, data:NSData!, error: NSError!) -> Void in
            
            var jsonerror : NSError?
            
            let jsonObject : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonerror)
            
            if jsonerror == nil {
                if let dic = jsonObject as? NSDictionary {
                    // 格式化日期
                    let dateStr = dic["date"] as! String
                    let date : Date = Date.dateFromString(dateStr, format: "yyyyMMdd")
                    
                    var rawStories = dic.objectForKey("stories") as! NSArray
                    
                    // 将新下载的文章加入字典，并维护当前所有已下载文章的日期列表
                    self.dailyStories[date] = self.parseStories(rawStories)
                    
                    if self.hasDownloadedStoriesOnDate(date) == false {
                        self.dates.append(date)
                        self.dates.sort({ (lop : Date, rop : Date) -> Bool in
                            if lop.hashValue > rop.hashValue {
                                return true
                            }
                            return false
                        })
                    }
                    
                    // 在主线程中更新UI
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        self.storiesListTableView.reloadData()
                        
                        if self.isLoadingMoreStories == true {
                            self.isLoadingMoreStories = false
                        }
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
        
        var cell = self.storiesListTableView.dequeueReusableCellWithIdentifier(Consts.StoryDescriptionCellID, forIndexPath: indexPath) as? StoryDescriptionCell
        
        if cell == nil {
            cell = StoryDescriptionCell(style: UITableViewCellStyle.Default, reuseIdentifier: Consts.StoryDescriptionCellID)
        }
        
        let date = self.dates[indexPath.section]

        let story = self.dailyStories[date]![indexPath.row]
        
        
        cell?.storyTitle.text = story.title

        if story.imageUrl != nil {
            cell?.storyImage.loadImageFromUrl(story.imageUrl!)
        }
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*
        println(section)
        for item in self.dates {
            println(item)
        }
*/
        let date = self.dates[section]
        return date.toString("MM月dd日") + " " + date.weekdayStr
    }
    
    
    
    

    // 返回单元格高度
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return StoryDescriptionCell.Height
    }*/
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return StoryDescriptionCell.Height
    }
    

    
    
    
    
    
    // 下载最新文章,并初始化文章列表和Top Stories
    func downloadLatestStories() {
        let nsurl = NSURL(string: Consts.LatestStoriesUrl)
        let urlRequest = NSMutableURLRequest(URL: nsurl!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = "GET"
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response : NSURLResponse!, data:NSData!, error: NSError!) -> Void in
            
            var jsonerror : NSError?
            
            let jsonObject : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonerror)
            

            if jsonerror == nil {
                if let dic = jsonObject as? NSDictionary {
                    // 格式化日期
                    let dateStr = dic["date"] as! String
                    let date : Date  = Date.dateFromString(dateStr, format: "yyyyMMdd")
                    
                    //println("dateStr = \(dateStr)")
                    //println("date = \(date)")

                
                    var rawStories = dic.objectForKey("stories") as! NSArray
                    var rawTopStories = dic.objectForKey("top_stories") as! NSArray
                    
                    
                    // 将新下载的文章加入字典，并维护当前所有已下载文章的日期列表
                    self.dailyStories[date] = self.parseStories(rawStories)
                    
                    if self.dates.count == 0 {

                        self.dates.append(date)
                    }
                    
                    
                    // 解析Top Stories
                    self.topStories = self.parseTopStories(rawTopStories)
                    
                    
                    // 在主线程中更新UI
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        self.storiesListTableView.reloadData()
                        
                        self.pageControl.numberOfPages = self.topStories.count
                        
                        self.pageControl.currentPage = self.topStoriesScrollView.currentImage
                        
                        self.topStoryTitle.text = self.topStories[self.pageControl.currentPage].title
                        
                        if self.pullRefreshControl.refreshing == true {
                            self.pullRefreshControl.endRefreshing()
                        }
                    })
                    
                    
                
                    // 更新Scroll View视图
                    var imgUrls : [String] = []
                    for topStory in self.topStories {
                        var url = topStory.imageUrl
                        imgUrls.append(url!)
                    }
                    
                    //self.topStoriesScrollView.initWithImageUrls(imgUrls)
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
    
    func hasDownloadedStoriesOnDate(date : Date) -> Bool {
        for item in self.dates {
            if item == date {
                return true
            }
        }
        
        return false
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
    
    
    // 解析Top Stories内容，同样以Story的格式存储
    func parseTopStories(rawStories : NSArray) -> [Story] {
        var stories : [Story] = []
        
        for storyObj in rawStories {
            let title = storyObj.objectForKey("title") as! String
            
            let id = (storyObj.objectForKey("id") as! NSNumber).stringValue
            
            let imageUrl = storyObj.objectForKey("image") as! String
            
            let story = Story(title: title, id: id, imageUrl: imageUrl)
            
            stories.append(story)
        }
        return stories
    }
    
    

    // TopStoriesScrollView的delegate方法
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.topStoriesScrollView {
            self.topStoriesScrollView.updateScrollView()
            self.pageControl.currentPage = self.topStoriesScrollView.currentImage
            self.topStoryTitle.text = self.topStories[self.pageControl.currentPage].title
        }
    }
    

    
    
    
}