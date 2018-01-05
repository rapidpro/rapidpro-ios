//
//  URContact.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URContact: Mappable {
   
    var uuid:String?
    var name:String?
    var phoneNumber:String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        uuid <- map["uuid"]
        name <- map["name"]
        phoneNumber <- map["phoneNumber"]
    }
}
