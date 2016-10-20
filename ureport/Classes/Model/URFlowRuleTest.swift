//
//  URFlowRuleTest.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowRuleTest: Mappable {
    
    var test:[String : String] = [:]
    var base:String?
    var type:String?
    var min:String?
    var max:String?
    
    required init?(_ map: Map){}
    
    func mapping(_ map: Map) {
        self.test        <- map["test"]
        self.base        <- map["base"]
        self.type        <- map["type"]
        self.min         <- map["min"]
        self.max         <- map["max"]
    }
}
