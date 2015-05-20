//
//  StoriesTableViewController.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/14.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class StoriesTableViewController : UITableViewController {

    
    @IBOutlet weak var headerView: UIView!
    
    var count = 10
    
    
    override func viewDidLoad() {



        //self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)

        
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let value = indexPath.section * 10 + indexPath.row
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        cell.textLabel?.text = String(value)
        
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let lvalue = section * 10 + 0
        let rvalue = section * 10 + 9
        let str = "\(lvalue) ~ \(rvalue)"
        return str
    }
}
