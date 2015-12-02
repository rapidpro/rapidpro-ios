//
//  URGcmChatMessage.swift
//  ureport
//
//  Created by John Dalton Costa Cordeiro on 01/12/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper

class URGcmChatMessage: Serializable {
    
    var chatRoom:URChatRoom?
    var chatMessage:URChatMessage?
    
    init(chatRoom:URChatRoom?, chatMessage:URChatMessage?) {
        self.chatRoom = chatRoom
        self.chatMessage = chatMessage
    }
    
    func convertToDictionary() -> [String : AnyObject] {
        return [
            "chatRoom": self.chatRoom!.toDictionary(),
            "chatMessage": self.chatMessage!.toDictionary()
        ]
    }
    
}
