//
//  URAPIResponse.swift
//  ureport
//
//  Created by Daniel Amaral on 29/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URAPIResponse<T:Mappable>: Mappable {

    var results:[T]!
    
    required init?(_ map: Map){}
    
    func mapping(map: Map) {
        self.results    <- map["results"]
    }
    
}
