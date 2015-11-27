//
//  URGCMManager.swift
//  ureport
//
//  Created by Daniel Amaral on 03/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URGCMManager: NSObject {
 
    static let topic = "/topics/"
    static let registrationKey = "onRegistrationCompleted"
    static let messageKey = "onMessageReceived"
    
    class func registerUserInTopic(user:URUser,chatRoom:URChatRoom) {
        
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                GCMPubSub.sharedInstance().subscribeWithToken(user.pushIdentity, topic: "\(self.topic)\(chatRoom.key)",
                    options: nil, handler: {(NSError error) -> Void in
                        if (error != nil) {
                            // Treat the "already subscribed" error more gently
                            if error.code == 3001 {
                                print("Already subscribed to topic")
                            } else {
                                print("Subscription failed: \(error.localizedDescription)");
                            }
                        } else {
                            NSLog("Subscribed to topic");
                        }
                })
            }
        })
        
    }
    
    class func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            if let user = URUser.activeUser() {
                if (user.pushIdentity == nil || user.pushIdentity.isEmpty) || (!user.pushIdentity.isEmpty && (user.pushIdentity != registrationToken)){
                    user.pushIdentity = registrationToken
                    URUserManager.updatePushIdentity(user)
                }
            }
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
        }
    }
    
}
