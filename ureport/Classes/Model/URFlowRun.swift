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
    
    var flow:URFlow!
    var exit_type:String?
    //var expires_on:Date!
    //var expired_on:Date!
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        self.flow  <- map["flow"]
        self.exit_type  <- map["exit_type"]
        //self.expires_on <- (map["expires_on"], URRapidPRODateTransform())
        //self.expired_on <- (map["expired_on"], URRapidPRODateTransform())
    }
}
