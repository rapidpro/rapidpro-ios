//
//  URPollCategory.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import FirebaseDatabase
import ObjectMapper

class URPollCategory: Mappable {
   
    var name:String!
    var image_url:String!
    var color:UIColor!
    
    required init?(map: Map) { }

    func mapping(map: Map) {
        name <- map["name"]
        image_url <- map["image_url"]
        color <- (map["color"], HexColorTransform())        
    }
}
