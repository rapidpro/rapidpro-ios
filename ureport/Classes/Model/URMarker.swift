//
//  URMarker.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseDatabase

class URMarker: Mappable {
   
    var name:String!
    
    init(name:String){
        self.name = name
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        name <- map["name"]
    }
}
