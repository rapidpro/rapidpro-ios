//
//  URState.swift
//  ureport
//
//  Created by Daniel Amaral on 25/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URState: NSObject {

    var name:String!
    var boundary:String!
    
    init(name:String,boundary:String?) {
        super.init()
        self.name = name
        self.boundary = boundary
    }
    
}
