//
//  HomeViewController.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/17.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit


class HomeViewController: UITableViewController {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var topStoriesScrollView: LoopedScrollView!
    
    
    
    // 文章集合，按日期分类
    var dailyStories = [Date:[Story]]()
    
    // 所有文章的日期，按降序排列
    var dates = [Date]()
    
    // Slide页展示的Top Stories
    var topStories = [Story]()
    
    // 下拉刷新控件
    var isLoadingMoreStories : Bool = false
    
    
    override func viewDidLoad() {
        // 设置Navigationbar相关属性
        self.navigationController?.navigationBar.backgroundColor = Consts.BlueColor
        self.navigationController?.navigationBar.translucent = false
        
        
        // 设置SWRevealViewController相关属性
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = Selector("revealToggle:")
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            self.revealViewController().rearViewRevealWidth = 200
        }
        
        
        // 设置tableView相关属性
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = true
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        self.tableView.estimatedRowHeight = StoryDescriptionCell.Height
        self.tableView.tableFooterView?.hidden = false
        
        // 注册tableView单元格
        let nib = UINib(nibName: "StoryDescriptionCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: Consts.StoryDescriptionCellID)
        
        // 设置下拉刷新控件
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "正在更新内容")
        self.refreshControl!.addTarget(self, action: "downloadLatestStories", forControlEvents: UIControlEvents.ValueChanged)
        
        
        
        
        // 下载最新文章
        self.downloadLatestStories()
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
                        self.tableView.reloadData()
                        
                        if self.refreshControl!.refreshing == true {
                            self.refreshControl!.endRefreshing()
                        }
                    })
                    
                    
                    // 更新Scroll View视图
                    var imgUrls : [String] = []
                    for topStory in self.topStories {
                        var url = topStory.imageUrl
                        imgUrls.append(url!)
                    }
                    self.topStoriesScrollView.initWithFrameAndImageUrls(CGRectMake(0, 0, self.view.frame.width, 180), imageUrls: imgUrls)
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
    
    
    
    
    // 获取Section数目
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dates.count
    }
    
    // 获取每个Section有多少文章
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section < self.dates.count, "No stories in section \(section)")
        let date = self.dates[section]
        
        assert(self.dailyStories[date] != nil, "Story not found on day \(date)")
        return self.dailyStories[date]!.count
    }
    
    
    
    // 获取文章简介的单元格
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier(Consts.StoryDescriptionCellID, forIndexPath: indexPath) as? StoryDescriptionCell
        
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
    
    // 设置每个section的header
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = Consts.BlueColor
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(15)
        
        let date = self.dates[section]
        label.text =  date.toString("MM月dd日") + " " + date.weekdayStr
        
        return label
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    
    // 将footer view的高度设置为0.1，近似隐藏footer view
    /*
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    */
    
    
    
    
    // 上拉列表，载入更多文章
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isEqual(self.tableView) {
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
        if self.dates.count == 0 {
            self.isLoadingMoreStories = false
            return
        }
        
        
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
                        self.tableView.reloadData()
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
    
    // 判断是否下载过某日的文章
    func hasDownloadedStoriesOnDate(date : Date) -> Bool {
        for item in self.dates {
            if item == date {
                return true
            }
        }
        
        return false
    }
    
}