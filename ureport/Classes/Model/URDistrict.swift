//
//  URDistrict.swift
//  ureport
//
//  Created by Daniel Amaral on 25/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URDistrict: NSObject {

    var name:String!
    var parent:String!
    
    init(name:String,parent:String) {
        super.init()
        self.name = name
        self.parent = parent
    }
    
}
