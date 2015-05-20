//
//  StorySectionHeaderCell.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/19.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit

class StorySectionHeaderCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.textAlignment = NSTextAlignment.Center
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}