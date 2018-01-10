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

class URGCMManager {

    static let chatTopic = "/topics/chats-"

    private static let chatTopicsPath = "chats-"
    private static let storyTopicsPath = "story-"

    static let registrationKey = "onRegistrationCompleted"
    static let messageKey = "onMessageReceived"

    static func onFCMRegistered(user: URUser) {
        registerUserToChatTopics(user)
//        registerToStoryTopics(user: user)
    }

    class func handleNotification(_ userData:[AnyHashable: Any]) {
        let from = userData["from"] as! String
        if from.hasPrefix(chatTopic) {
            let chatMessageDict = convertJsonToDictionary(userData["chatMessage"] as! String)!
            let chatMessage = URChatMessage(JSON: chatMessageDict)
            let user = URUser(JSON: (chatMessageDict["user"] as? [String: Any] ?? [:]))
            
            if isUserAllowedForMessageNotification(user) {
                print("Chat notifiction: \(chatMessage)")
            }
        }
    }

    fileprivate class func convertJsonToDictionary(_ value:String) -> [String:Any]? {
        if let data = value.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
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

    class func registerUserToChatTopics(_ user: URUser) {
        guard let fcmToken = user.pushIdentity else { return }
        
        if let userCountryString = user.country, let programCode = URCountryProgramManager.getCountryProgramByCountry(URCountry(code: userCountryString)).code, let token = URCountryProgramManager.getChannelToken(for: programCode) {
            URFcmAPI.registerOnTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: token))
        }

        URUserManager.getChatRooms(user, completion: { chatRooms in
            guard let chatRooms = chatRooms else { return }
            for chatRoom in chatRooms {
                URFcmAPI.registerOnTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoom))
            }
        })
    }

    static public func registerUserToChatTopic(user: URUser, chatRoomKey: String) {
        guard let fcmToken = user.pushIdentity else { return }
        URFcmAPI.registerOnTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoomKey))
    }

    static public func unregisterUserFromChatTopic(user: URUser, chatRoomKey: String) {
        guard let fcmToken = user.pushIdentity else { return }
        URFcmAPI.unregisterFromTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoomKey))
    }

    class func registerUserInTopic(_ user:URUser,chatRoom:URChatRoom) {
        guard let fcmToken = user.pushIdentity else { return }
        URFcmAPI.registerOnTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoom.key!))
    }

    class func notifyChatMessage(_ chatRoom:URChatRoom, chatMessage:URChatMessage) {
        let message = chatMessage.message != nil ? chatMessage.message! : "label_chat_picture_notification".localized
        chatMessage.message = message

        let input:URGcmInput = URGcmInput(to: "\(self.chatTopic)\(chatRoom.key!)", data: buildChatMessageData(chatRoom, chatMessage: chatMessage))
        input.notification = URGcmNotification(title: "New chat message", body: "\(chatMessage.user.nickname!): \(chatMessage.message!)",type: URConstant.NotificationType.CHAT)

        let param = Mapper<URGcmInput>().toJSON(input)

        URFcmAPI.sendChatNotification(data: param)
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

    private static func topicByName(topic: String, key: String) -> String {
        return "\(topic)\(key)"
    }
}
