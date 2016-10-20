//
//  URNewsCategory.swift
//  ureport
//
//  Created by Daniel Amaral on 29/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URNewsCategory: Mappable {

    var imageUrl:String!
    var name:String!
    
    required init?(_ map: Map){}
    
    func mapping(_ map: Map) {
        self.imageUrl    <- map["image_url"]
        self.name        <- map["name"]
    }
    
}
