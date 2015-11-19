//
//  URGroupChatRoom.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URGroupChatRoom: URChatRoom {
   
    var mediaAllowed:NSNumber!
    var administrator:URUser!
    var picture:URMedia!
    var privateAccess:NSNumber!
    var title:String!
    var subject:String!
    var userIsMember:Bool!
}
