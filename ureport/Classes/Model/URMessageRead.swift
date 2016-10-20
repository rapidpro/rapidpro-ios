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
        
    class func saveMessageReadLocaly(_ messageRead:URMessageRead) {
        
        let defaults = UserDefaults.standard
        var readArray:[NSDictionary] = URMessageRead.getMessagesRead()
        
        if let _ = readArray.index(of: messageRead.toDictionary()) {
            return
        }else {
            readArray.append(messageRead.toDictionary())
        }
        
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: readArray), forKey: "messagesRead")
        defaults.synchronize()
    }
    
    class func getMessagesRead() -> [NSDictionary]{
        
        let defaults = UserDefaults.standard
        let readArray:[NSDictionary] = []
        
        if let messagesRead = defaults.object(forKey: "messagesRead") as? Data {
            return (NSKeyedUnarchiver.unarchiveObject(with: messagesRead)) as! [NSDictionary]
        }
        
        return readArray
    }
    
}
