//
//  URFlowRun.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowRun: Mappable {
    
    var flow_uuid:String!
    var flow:Int!
    var completed:Bool!
    var expires_on:NSDate!
    var expired_on:NSDate!
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        self.flow_uuid  <- map["flow_uuid"]
        self.flow       <- map["flow"]
        self.completed  <- map["completed"]
        self.expires_on <- (map["expires_on"], URRapidPRODateTransform())
        self.expired_on <- (map["expired_on"], URRapidPRODateTransform())
    }
}
