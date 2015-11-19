//
//  URFlowTypeValidation.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 19/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URFlowTypeValidation {
    
    var type:URFlowType!
    var validation:String!
    var message:String!
    
    init(type: URFlowType, validation: String, message: String) {
        self.type = type
        self.validation = validation
        self.message = message
    }

}
