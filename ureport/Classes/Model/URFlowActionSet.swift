//
//  URFlowActionSet.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlowActionSet: Mappable {
    
    var positionX:Int?
    var positionY:Int?
    var destination:String?
    var uuid:String?
    var actions:[URFlowAction]?
    
    required init?(_ map: Map){}
    
    func mapping(_ map: Map) {
        self.positionX    <- map["x"]
        self.positionY    <- map["y"]
        self.destination  <- map["destination"]
        self.uuid         <- map["uuid"]
        self.actions      <- map["actions"]
    }
}
