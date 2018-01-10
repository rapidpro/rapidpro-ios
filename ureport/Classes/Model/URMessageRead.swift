//
//  URMessageRead.swift
//  ureport
//
//  Created by Daniel Amaral on 02/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URMessageRead: Mappable {
   
    var totalMessages: NSNumber!
    var roomKey: String!
    
    init() {}
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        totalMessages <- map["totalMessages"]
        roomKey <- map["roomKey"]
    }
    
    class func saveMessageReadLocaly(_ messageRead:URMessageRead) {
        var readArray = URMessageRead.getMessagesRead()
        
        guard readArray.index(where: {$0.totalMessages == messageRead.totalMessages && $0.roomKey == messageRead.roomKey}) == nil else {
            return
        }
       
        readArray.append(messageRead)
        UserDefaults.standard.setAsStringArray(objects: readArray, key: "messagesRead")
    }
    
    class func getMessagesRead() -> [URMessageRead] {
        var readArray: [URMessageRead] = []
        
        if let messagesRead = UserDefaults.standard.getArchivedObject(key: "messagesRead") as? [String] {
            for messageRead in messagesRead {
                if let message = URMessageRead(JSONString: messageRead) {
                    readArray.append(message)
                }
            }
        }
        
        return readArray
    }
    
}
