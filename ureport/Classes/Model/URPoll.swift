//
//  URPoll.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPoll: Serializable {
    
    var key:String!
    var title:String!
    var expiration_date:String!
    var flow_uuid:String!
    var percent_rate:String!
    var polled:String!
    var responded:String!
    var category:URPollCategory!
    
}
