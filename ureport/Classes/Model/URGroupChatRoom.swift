//
//  URGroupChatRoom.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URGroupChatRoom: URChatRoom {
   
    var mediaAllowed:NSNumber?
    var administrator:URUser!
    var picture:URMedia?
    var privateAccess:NSNumber!
    var title:String!
    var subject:String!
    var userIsMember:Bool?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.mediaAllowed <- map["mediaAllowed"]
        self.administrator <- map["administrator"]
        self.picture <- map["picture"]
        self.privateAccess <- map["privateAccess"]
        self.title <- map["title"]
        self.subject <- map["subject"]
        self.userIsMember <- map["userIsMember"]
    }
}
