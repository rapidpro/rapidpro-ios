//
//  URContribution.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URContribution: Mappable {
    
    var key:String?
    var content:String!
    var author:URUser!
    var createdDate:NSNumber!
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["key"]
        content <- map["content"]
        author <- map["author"]
        createdDate <- map["createdDate"]
    }
}
