//
//  URMessageRead.swift
//  ureport
//
//  Created by Daniel Amaral on 02/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMessageRead: Serializable {
   
    var totalMessages:NSNumber!
    var roomKey:String!
        
    class func saveMessageReadLocaly(messageRead:URMessageRead) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var readArray:[NSDictionary] = URMessageRead.getMessagesRead()
        
        if let _ = readArray.indexOf(messageRead.toDictionary()) {
            return
        }else {
            readArray.append(messageRead.toDictionary())
        }
        
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(readArray), forKey: "messagesRead")
        defaults.synchronize()
    }
    
    class func getMessagesRead() -> [NSDictionary]{
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let readArray:[NSDictionary] = []
        
        if let messagesRead = defaults.objectForKey("messagesRead") as? NSData {
            return (NSKeyedUnarchiver.unarchiveObjectWithData(messagesRead)) as! [NSDictionary]
        }
        
        return readArray
    }
    
}
