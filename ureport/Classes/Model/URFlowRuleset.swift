//
//  URFlowRuleset.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowRuleset: Mappable {
    
    var uuid:String?
    var webhookAction:String?
    var rules:[URFlowRule]?
    var webhook:String?
    var rulesetType:String?
    var label:String?
    var operand:String?
    var labelKey:String?
    var responseType:String?
    var positionX:Int?
    var positionY:Int?
    
    required init?(_ map: Map){}
    
    func mapping(_ map: Map) {
        self.uuid          <- map["uuid"]
        self.webhookAction <- map["webhook_action"]
        self.rules         <- map["rules"]
        self.webhook       <- map["webhook"]
        self.rulesetType   <- map["ruleset_type"]
        self.label         <- map["label"]
        self.operand       <- map["operand"]
        self.labelKey      <- map["label_key"]
        self.responseType  <- map["response_type"]
        self.positionX     <- map["x"]
        self.positionY     <- map["y"]
    }
}
