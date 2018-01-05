//
//  URGcmChatMessage.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 01/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URGcmChatMessage: Mappable {
    
    var chatRoom:URChatRoom?
    var chatMessage:URChatMessage?
    
    init(chatRoom:URChatRoom?, chatMessage:URChatMessage?) {
        self.chatRoom = chatRoom
        self.chatMessage = chatMessage
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        chatRoom <- map["chatRoom"]
        chatMessage <- map["chatMessage"]
    }
}
