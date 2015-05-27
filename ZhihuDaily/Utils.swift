//
//  Utils.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/27.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation
import UIKit


struct Utils {
    static func convertNSArrayToStringArray(array : NSArray) -> [String] {
        var result : [String] = []
        for item in array {
            let str = item as! String
            result.append(str)
        }
        return result
    }
}