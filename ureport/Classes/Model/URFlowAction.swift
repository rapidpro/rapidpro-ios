//
//  URFlowAction.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowAction: Mappable {
    
    var message: [String : String] = [:]
    var type:String?
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        self.message    <- map["msg"]
        self.type       <- map["type"]
    }
}
