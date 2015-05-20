//
//  TestViewController.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/16.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nav: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.nav.topItem?.title = "Numbers"

    }
    
    
    override func viewDidLoad() {
        
        //self.navigationItem.title = "Numbers"
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    var count = 10

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let value = indexPath.section * 10 + indexPath.row
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        cell.textLabel?.text = String(value)
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let lvalue = section * 10 + 0
        let rvalue = section * 10 + 9
        let str = "\(lvalue) ~ \(rvalue)"
        return str
    }
}