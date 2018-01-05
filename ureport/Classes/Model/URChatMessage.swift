//
//  URChatMessage.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ObjectMapper

class URChatMessage: Mappable {
    
    var key:String?
    var message:String?
    var user:URUser!
    var date:NSNumber!
    var media:URMedia?
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["key"]
        message <- map["message"]
        user <- map["user"]
        date <- map["date"]
        media <- map["media"]
    }
    
    func text() -> String! {
        return self.message
    }
    
    func sender() -> String! {
        return self.user.nickname
    }
}
