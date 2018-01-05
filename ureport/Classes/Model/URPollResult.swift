//
//  URPollResult.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseDatabase

class URPollResult: Mappable {
   
    var date:String!
    var polled:String!
    var responded:String!
    var title:String!
    var type:String!
    var results:[NSDictionary]!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        date <- map["date"]
        polled <- map["polled"]
        responded <- map["responded"]
        title <- map["title"]
        type <- map["type"]
        results <- map["results"]
    }
}
