//
//  URGCMManager.swift
//  ureport
//
//  Created by Daniel Amaral on 03/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URGCMManager: NSObject {
 
    static let chatTopic = "/topics/chats-"
    
    static let registrationKey = "onRegistrationCompleted"
    static let messageKey = "onMessageReceived"
    
    class func handleNotification(userData:[NSObject : AnyObject]) {
        print("Notification received: \(userData)")
        let from = userData["from"] as! String
        if from.hasPrefix(chatTopic) {
            let chatMessageDict = convertJsonToDictionary(userData["chatMessage"] as! String)
            let chatMessage = URChatMessage(jsonDict: chatMessageDict)
            let user = URUser(jsonDict: (chatMessageDict!["user"] as? NSDictionary))
            
            if isUserAllowedForMessageNotification(user) {
                let localNotification:UILocalNotification = UILocalNotification()
                localNotification.alertBody = "\(user.nickname): \(chatMessage.text())"
                localNotification.fireDate = NSDate()
                localNotification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
        }
    }
    
    private class func convertJsonToDictionary(value:String) -> NSDictionary? {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
            } catch {
                print("Error on converting json to dictionary!")
            }
        }
        return nil
    }
    
    private class func isUserAllowedForMessageNotification(user:URUser?) -> Bool {
        return URUser.activeUser() != nil && user != nil
            && user!.key != URUser.activeUser()?.key
    }
    
    class func registerUserInTopic(user:URUser,chatRoom:URChatRoom) {
        if user.pushIdentity != nil {
            GCMPubSub.sharedInstance().subscribeWithToken(user.pushIdentity, topic: "\(self.chatTopic)\(chatRoom.key)",
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
