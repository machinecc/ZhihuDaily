//
//  StoryCell.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/13.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit


class StoryDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var storyTitle: UILabel!
    
    @IBOutlet weak var storyImage: UIImageViewAsync!

    static let Height : CGFloat = 80.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
