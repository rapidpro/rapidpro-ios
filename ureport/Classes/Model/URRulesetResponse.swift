//
//  URRulesetResponse.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 23/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URRulesetResponse {
    
    var rule:URFlowRule!
    var response:String!
    
    init (rule:URFlowRule, response:String) {
        self.rule = rule
        self.response = response
    }

}
