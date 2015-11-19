//
//  URPollResponse.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPollResponse: Serializable {
   
    var channel:String!
    var from:String!
    var text:String!
    
    init(channel:String, from:String, text:String) {
        self.channel = channel
        self.from = from
        self.text = text
    }        
    
}
