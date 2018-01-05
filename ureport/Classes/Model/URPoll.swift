//
//  URPoll.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseDatabase

class URPoll: Mappable {
    
    var key:String!
    var title:String!
    var expiration_date:String!
    var flow_uuid:String!
    var percent_rate:String!
    var polled:String!
    var responded:String!
    var category:URPollCategory!
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["key"]
        title <- map["title"]
        expiration_date <- map["expiration_date"]
        flow_uuid <- map["flow_uuid"]
        percent_rate <- map["percent_rate"]
        polled <- map["polled"]
        responded <- map["responded"]
        category <- map["category"]
    }
}
