//
//  Articles.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/4.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

struct StoryDetail {
    // 首页和子日报的文章数据格式有差别，storyType = 0 代表首页文章，storyType = 1 代表子日报文章
    var storyType : Int
    
    // 公共数据部分
    var body : String
    var title : String
    var recommenders : [Dictionary<String,String>]
    var share_url : String
    var js : [String]
    var ga_prefix : String
    var type : Int
    var id : Int
    var css : [String]
    
    // 首页文章特有数据
    var image_source : String
    var image : String
    
    // 子日报文章
    var theme : [String:String]

    
    

    
    
    static func initWithJsonData(jsonObject : AnyObject?) -> StoryDetail? {
        if let dic = jsonObject as? NSDictionary {
            // 解析Story共有的内容部分
            let body = dic["body"] as! String
            let title = dic["title"] as! String
            // TODO: Parse recommenders
            var recommenders : [Dictionary<String,String>] = []
            let share_url = dic["share_url"] as! String
            let raw_js = dic["js"] as! NSArray
            let js = Utils.convertNSArrayToStringArray(raw_js)
            let ga_prefix = dic["ga_prefix"] as! String
            let type = dic["type"] as! Int
            let id = dic["id"] as! Int
            let raw_css = dic["css"] as! NSArray
            let css = Utils.convertNSArrayToStringArray(raw_css)
            
            
            var storyType = 0
            var image_source : String = ""
            var image : String = ""
            var theme  = [String:String]()
            
            // 确定Story的类型,并解析特有的内容
            if dic["image"] != nil {
                storyType = 0
                image_source = dic["image_source"] as! String
                image = dic["image"] as! String
            }
            else {
                storyType = 1
                // TODO: Parse theme
            }
            
            let storyDetail = StoryDetail(storyType: storyType, body: body, title: title, recommenders: recommenders, share_url: share_url, js: js, ga_prefix: ga_prefix, type: type, id: id, css: css, image_source: image_source, image: image, theme: theme)
            
            return storyDetail
        }
        
        NSLog("json data parse failed for selected story")
        
        return nil
    }
    
    
    
    // 判断是否首页文章
    func isOnHomePage() -> Bool {
        return self.storyType == 0
    }
}









