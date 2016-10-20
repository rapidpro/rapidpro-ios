//
//  URNews.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URNews: Mappable {
 
    var id:Int!
    var title:String!
    var featured:Bool!
    var summary:String!
    var org:NSNumber!
    var images:[String]!
    var tags:String!
    var category:URNewsCategory!
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        self.id         <- map["id"]
        self.title      <- map["title"]
        self.featured   <- map["featured"]
        self.summary    <- map["summary"]
        self.org        <- map["org"]
        self.images     <- map["images"]
        self.tags       <- map["tags"]
        self.category   <- map["category"]
    }
    
}
