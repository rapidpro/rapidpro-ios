//
//  URFlowRule.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowRule: Mappable {
    
    var ruleCategory:[String : String] = [:]
    var test:URFlowRuleTest?
    var destination:String?
    var uuid:NSString?
    var destinationType:NSString?
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        self.ruleCategory       <- map["category"]
        self.test               <- map["test"]
        self.destination        <- map["destination"]
        self.uuid               <- map["uuid"]
        self.destinationType    <- map["destination_type"]
    }
}
