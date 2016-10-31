//
//  URGCMManager.swift
//  ureport
//
//  Created by Daniel Amaral on 03/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class URGCMManager: NSObject {
    
    static let chatTopic = "/topics/chats-"
    
    static let registrationKey = "onRegistrationCompleted"
    static let messageKey = "onMessageReceived"
    
    class func handleNotification(_ userData:[AnyHashable: Any]) {
        let from = userData["from"] as! String
        if from.hasPrefix(chatTopic) {
            let chatMessageDict = convertJsonToDictionary(userData["chatMessage"] as! String)
            let chatMessage = URChatMessage(jsonDict: chatMessageDict)
            let user = URUser(jsonDict: (chatMessageDict!["user"] as? NSDictionary))
            
            if isUserAllowedForMessageNotification(user) {
                print("Chat notifiction: \(chatMessage)")
            }
        }
    }
    
    fileprivate class func convertJsonToDictionary(_ value:String) -> NSDictionary? {
        if let data = value.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            } catch {
                print("Error on converting json to dictionary!")
            }
        }
        return nil
    }
    
    fileprivate class func isUserAllowedForMessageNotification(_ user:URUser?) -> Bool {
        return URUser.activeUser() != nil && user != nil
            && user!.key != URUser.activeUser()?.key
    }
    
    class func registerUserInTopic(_ user:URUser,chatRoom:URChatRoom) {
        if user.pushIdentity != nil {
            GCMPubSub.sharedInstance().subscribe(withToken: user.pushIdentity, topic: "\(self.chatTopic)\(chatRoom.key)",
                                                          options: nil, handler: {(error) -> Void in
                                                            if (error != nil) {
                                                                print("Subscription failed: \(error?.localizedDescription)")
                                                            } else {
                                                                NSLog("Subscribed to topic");
                                                            }
            })
        }
    }
    
    class func notifyChatMessage(_ chatRoom:URChatRoom, chatMessage:URChatMessage) {
        let headers = [
            "Authorization": URConstant.Gcm.GCM_AUTHORIZATION
        ]
        
        let message = chatMessage.message != nil ? chatMessage.message! : "label_chat_picture_notification".localized
        chatMessage.message = message
        
        let input:URGcmInput = URGcmInput(to: "\(self.chatTopic)\(chatRoom.key)", data: buildChatMessageData(chatRoom, chatMessage: chatMessage))
        input.notification = URGcmNotification(title: "New chat message", body: "\(chatMessage.user.nickname): \(chatMessage.message!)",type: URConstant.NotificationType.CHAT)
        
        let param = Mapper<URGcmInput>().toJSON(input)
        
        Alamofire.request(URConstant.Gcm.GCM_URL, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).debugLog()
    }
    
    class func buildChatMessageData(_ chatRoom:URChatRoom, chatMessage:URChatMessage) -> [String : AnyObject] {
        let chatMessageDict:[String : AnyObject] = [
            "message": chatMessage.message! as AnyObject,
            "date": URDateUtil.dateFormatterRapidPro(Date(timeIntervalSince1970: NSNumber(value: chatMessage.date.doubleValue/1000 as Double) as TimeInterval)) as AnyObject,
            "user": buildUserData(chatMessage.user) as AnyObject
        ]
        return [
            "chatMessage": chatMessageDict as AnyObject,
            "chatRoom": ["key": chatRoom.key] as AnyObject
        ];
    }
    
    class func buildUserData(_ user:URUser) -> [String : AnyObject] {
        return [
            "key": user.key! as AnyObject,
            "nickname": user.nickname! as AnyObject
        ]
    }
    
    class func registrationHandler(_ registrationToken: String, error: NSError) {
        if (registrationToken != nil) {
            if let user = URUser.activeUser() {
                if (user.pushIdentity == nil || user.pushIdentity!.isEmpty) || (!user.pushIdentity!.isEmpty && (user.pushIdentity != registrationToken)){
                    user.pushIdentity = registrationToken
                    URUserManager.updatePushIdentity(user)
                }
            }
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
        }
    }
    
}
