//
//  URFlowDefinition.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowDefinition: Mappable {
    
    var baseLanguage:String?
    var actionSets:[URFlowActionSet]?
    var version:Int?
    var lastSaved:Date?
    var type:String?
    var entry:String?
    var ruleSets:[URFlowRuleset]?
    var metadata:URFlowMetadata?
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        self.baseLanguage    <- map["base_language"]
        self.actionSets      <- map["action_sets"]
        self.version         <- map["version"]
        self.lastSaved       <- (map["last_saved"], URRapidPRODateTransform())
        self.type            <- map["flow_type"]
        self.entry           <- map["entry"]
        self.ruleSets        <- map["rule_sets"]
        self.metadata        <- map["metadata"]
    }

}
