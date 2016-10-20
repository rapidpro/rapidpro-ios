//
//  URGcmInput.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 01/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URGcmInput : Mappable {
    
    var to:String?
    var data:[String : AnyObject] = [:]
    var priority:URGcmPriority? = URGcmPriority.high
    var notification:URGcmNotification?
    var type:String!
    
    init(to:String?, data:[String : AnyObject]) {
        self.to = to
        self.data = data
        priority = URGcmPriority.high
    }
    
    required init?(_ map: Map){}
    
    func mapping(_ map: Map) {
        self.to             <- map["to"]
        self.data           <- map["data"]
        self.priority       <- map["priority"]
        self.notification   <- map["notification"]
    }
    
}
