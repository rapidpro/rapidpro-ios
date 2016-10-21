//
//  URChatRoom.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URChatRoom: Serializable, Mappable {
    
    var key:String!
    var type:String!
    var createdDate:NSNumber!
    var lastMessage:URChatMessage!
    var totalUnreadMessages:Int!
    
    override init() {}
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        self.key <- map["key"]
    }
    
}
