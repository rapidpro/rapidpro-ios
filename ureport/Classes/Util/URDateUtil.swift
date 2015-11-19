//
//  URDateUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 09/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URDateUtil: NSObject {
   
    class func birthDayFormatter(date:NSDate) -> String{
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    class func birthDayFormatterRapidPro(date:NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm" //format style. Browse online to get a format that fits your needs.
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateFormatterRapidPro(date:NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateParserRapidPro(date:String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateFormatter.dateFromString(date)!
    }
    
    class func UTCDateFormatter(date:NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        return dateFormatter.stringFromDate(date)
    }
    
    class func getYear(date:NSDate) -> Int {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year, fromDate: date)
        return components.year        
    }
    
}
