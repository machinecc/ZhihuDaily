//
//  Date.swift
//  ZhihuDaily
//
//  Created by Xin on 15/5/14.
//  Copyright (c) 2015年 Xin. All rights reserved.
//

import Foundation

class Date : Hashable {
    var year : Int
    var month : Int
    var day : Int
    var weekday : Int
    
    
    var weekdayStr : String {
        var res : String = ""
        
        switch weekday {
            case 1:
                res = "星期一"
            case 2:
                res = "星期二"
            case 3:
                res = "星期三"
            case 4:
                res = "星期四"
            case 5:
                res = "星期五"
            case 6:
                res = "星期六"
            case 7:
                res = "星期日"
            default:
                assertionFailure("星期几计算出错")
        }
        
        return res
    }
    
    
    
    
    var hashValue : Int {
        return year * 10000 + month * 100 + day
    }
    
    static let daysPerMonthInLeapYears = [1:31, 2:29, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31]
    
    static let daysPerMonthInNonLeapYears = [1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31]

    
    init(year : Int, month : Int, day : Int) {
        self.year = year
        self.month = month
        self.day = day
        self.weekday = 0
        
        self.calculateWeekDay()
    }
    
    
    
    // 通过Kim larsson calculation formula计算星期几
    func calculateWeekDay() {
        var y = year
        var m = month
        var d = day
        
        if m == 1 || m == 2 {
            m = m + 12
            y = y - 1
        }
        self.weekday = (d+2*m+3*(m+1)/5+y+y/4-y/100+y/400) % 7 + 1
    }
    
    
    
    
    func nextDay() -> Date {
        var day = self.day + 1
        var month = self.month
        var year = self.year
        
        var daysInMonth = Date.daysPerMonthInNonLeapYears[month]
        
        if self.month == 2 && self.isLeapYear() == true {
            daysInMonth = Date.daysPerMonthInLeapYears[month]
        }
        
        if day > daysInMonth {
            day = 1
            
            month = month + 1
            
            if month > 12 {
                month = 1
                year = year + 1
            }
        }
        
        return Date(year: year, month: month, day: day)
    }
    
    
    func previousDay() -> Date {
        var day = self.day - 1
        var month = self.month
        var year = self.year
        
        if day < 1 {
            month = month - 1
            
            if month < 1 {
                month = 12
                year = year - 1
            }
            
            var daysInMonth = Date.daysPerMonthInNonLeapYears[month]
            
            if self.month == 2 && self.isLeapYear() == true {
                daysInMonth = Date.daysPerMonthInLeapYears[month]
            }
            
            day = daysInMonth!
        }
        
        return Date(year: year, month: month, day: day)
    }
    
    
    
    
    func isLeapYear() -> Bool {
        if year % 400 == 0 {
            return true
        }
        else if year % 100 == 0 {
            return false
        }
        else if year % 4 == 0 {
            return true
        }

        return false
    }
    
    
    func toString(format : String) -> String {
        var res = format.stringByReplacingOccurrencesOfString("yyyy", withString: self.intToStringWithPadding(self.year, intergerDigits: 4), options: NSStringCompareOptions.LiteralSearch, range: nil)

        res = res.stringByReplacingOccurrencesOfString("MM", withString: self.intToStringWithPadding(month, intergerDigits: 2), options: NSStringCompareOptions.LiteralSearch, range: nil)

        res = res.stringByReplacingOccurrencesOfString("dd", withString: self.intToStringWithPadding(self.day, intergerDigits: 2), options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return res
    }
    
    
    static func dateFromString(dateString : String, format : String) -> Date {
        let yrange = format.rangeOfString("yyyy")
        let resYear = dateString.substringWithRange(yrange!).toInt()!
        
        let mrange = format.rangeOfString("MM")
        let resMonth = dateString.substringWithRange(mrange!).toInt()!
        
        let drange = format.rangeOfString("dd")
        let resDay = dateString.substringWithRange(drange!).toInt()!
        
        return Date(year: resYear, month: resMonth, day: resDay)
    }
    
    
    
    
    
    private func intToStringWithPadding(number : Int, intergerDigits : Int) -> String {
        let str = NSString(format: "%0" + String(intergerDigits) + "d", number)
        return String(str)
    }
}


func == (lhs : Date, rhs : Date) -> Bool {
    return lhs.hashValue == rhs.hashValue
}