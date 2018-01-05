//
//  URPicture.swift
//  ureport
//
//  Created by Daniel Amaral on 31/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URMedia: Mappable {

    var id:String?
    var url:String!
    var type:String!
    var thumbnail:String?
    var isCover:Bool?
    var metadata:[String:AnyObject]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
        type <- map["type"]
        thumbnail <- map["thumbnail"]
        isCover <- map["isCover"]
        metadata <- map["metadata"]
    }
}
