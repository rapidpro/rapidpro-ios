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
    
    init(title:String?, body: String?) {
        self.title = title
        self.body = body
    }
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        self.title       <- map["title"]
        self.body        <- map["body"]
    }
}
