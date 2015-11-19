//
//  URPollResult.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPollResult: Serializable {
   
    var date:String!
    var polled:String!
    var responded:String!
    var title:String!
    var type:String!
    var results:[NSDictionary]!
    
}
