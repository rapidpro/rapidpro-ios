//
//  URFlow.swift
//  ureport
//
//  Created by Daniel Amaral on 09/05/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URFlow: Mappable {
    
    var uuid:String!
    var name:String!
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        self.uuid  <- map["uuid"]
        self.name  <- map["name"]
    }
}
