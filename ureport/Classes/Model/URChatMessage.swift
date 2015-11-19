//
//  URChatMessage.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit


class URChatMessage: Serializable, JSQMessageData {
    
    var key:String!
    var message:String!
    var user:URUser!
    var date:NSNumber!
    
    func text() -> String! {
        return self.message
    }
    
    func sender() -> String! {
        return self.user.nickname
    }
    
}
