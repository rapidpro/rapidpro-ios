//
//  URDateUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 09/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URDateUtil {
   
    class func birthDayFormatter(_ date:Date) -> String{
        return DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.none)
    }
    
    class func birthDayFormatterRapidPro(_ date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm" //format style. Browse online to get a format that fits your needs.
        return dateFormatter.string(from: date)
    }
    
    class func birthDayFormatterToGregorianCalendar(_ date:Date) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.date(from: dateFormatter.string(from: date))!
    }
    
    class func currentDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.date(from: dateFormatter.string(from: Date()))!
    }
    
    class func dateFormatterRapidPro(_ date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    class func dateParserRapidPro(_ date:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: date)!
    }
    
    class func UTCDateFormatter(_ date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    class func getYear(_ date:Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.year], from: date)
        return components.year!        
    }
    
}
