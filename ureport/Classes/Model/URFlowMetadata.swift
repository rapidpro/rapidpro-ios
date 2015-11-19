//
//  URFlowMetadata.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 17/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//


import UIKit
import ObjectMapper

class URFlowMetadata: Mappable {
    
    var uuid:String?
    var expires:Int?
    var name:String?
    var revision:Int?
    var id:Int?
    var savedOn:NSDate?
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        self.uuid           <- map["uuid"]
        self.expires        <- map["expires"]
        self.name           <- map["name"]
        self.revision       <- map["revision"]
        self.id             <- map["id"]
        self.savedOn        <- (map["save_on"], URRapidPRODateTransform())
    }
}
