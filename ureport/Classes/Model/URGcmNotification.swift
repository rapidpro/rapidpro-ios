//
//  URGcmNotification.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 01/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URGcmNotification : Mappable {
    
    var title:String?
    var body:String?
    var type:String!
    var sound:String!
    
    init(title:String?, body: String?,type:String!) {
        self.title = title
        self.body = body
        self.type = type
        self.sound = "default"
    }
    
    required init?(_ map: Map){}
    
    func mapping(_ map: Map) {
        self.title       <- map["title"]
        self.body        <- map["body"]
        self.type        <- map["type"]
        self.sound       <- map["sound"]
    }
}
