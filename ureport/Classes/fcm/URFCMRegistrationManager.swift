//
//  URFCMRegistrationService.swift
//  ureport
//
//  Created by Dielson Sales on 03/07/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit

class URFCMRegistrationManager {

    private static let chatTopicsPath = "chats-"
    private static let storyTopicsPath = "story-"

    static func onFCMRegistered(user: URUser) {
        registerToChatTopics(user: user)
        registerToStoryTopics(user: user)
    }

    // MARK:- Private methods

    static private func registerToChatTopics(user: URUser) {
        guard let fcmToken = user.pushIdentity else { return }
        URUserManager.getChatRooms(user, completion: { chatRooms in
            guard let chatRooms = chatRooms else { return }
            for chatRoom in chatRooms {
                URFcmAPI.registerOnTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoom))
            }
        })
    }

    static private func registerToChatTopic(user: URUser, chatRoomKey: String) {
        guard let fcmToken = user.pushIdentity else { return }
        URFcmAPI.registerOnTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoomKey))
    }

    static private func unregisterFromChatTopic(user: URUser, chatRoomKey: String) {
        guard let fcmToken = user.pushIdentity else { return }
        URFcmAPI.unregisterFromTopic(pushIdentity: fcmToken, topic: topicByName(topic: chatTopicsPath, key: chatRoomKey))
    }

    static private func registerToStoryTopics(user: URUser) {
    }

    private static func topicByName(topic: String, key: String) -> String {
        return "\(topic)\(key)"
    }

}
