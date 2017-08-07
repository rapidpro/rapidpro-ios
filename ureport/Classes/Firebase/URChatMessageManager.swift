//
//  URChatMessageManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

protocol URChatMessageManagerDelegate {
    func newMessageReceived(_ chatMessage:URChatMessage)
}

class URChatMessageManager {

    var delegate:URChatMessageManagerDelegate?

    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_messages"
    }
    
    func getMessages(_ chatRoom:URChatRoom) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatMessageManager.path())
            .child(chatRoom.key!)
            .observe(.childAdded, with: { (snapshot: DataSnapshot) in
                if let delegate = self.delegate {
                    let chatMessage = URChatMessage()
                    chatMessage.user = URUser(jsonDict: (snapshot.value as AnyObject).object(forKey: "user") as? NSDictionary)
                    chatMessage.message = (snapshot.value as AnyObject).object(forKey: "message") as? String
                    chatMessage.media = URMedia(jsonDict:(snapshot.value as AnyObject).object(forKey: "media") as? NSDictionary)
                    chatMessage.date = (snapshot.value as AnyObject).object(forKey: "date") as! NSNumber

                    print(snapshot.childrenCount)

                    if chatMessage.user.nickname != nil {
                        delegate.newMessageReceived(chatMessage)
                    }
                }
            })
    }
    
    class func getLastMessage(_ key:String,completion:@escaping (URChatMessage?) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(key)
            .queryLimited(toLast: 1)
            .observeSingleEvent(of: .value, with: { snapshot -> Void in
                guard snapshot.value != nil else {
                    completion(nil)
                    return
                }
                completion(URChatMessage(jsonDict:((snapshot.children.allObjects[0] as! DataSnapshot).value as? NSDictionary)))
            })
    }
    
    class func sendChatMessage(_ chatMessage:URChatMessage, chatRoom:URChatRoom) {
        URGCMManager.notifyChatMessage(chatRoom, chatMessage: chatMessage)

        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(chatRoom.key!)
            .childByAutoId()
            .setValue(chatMessage.toDictionary()) { (error, dbReference) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                if !dbReference.key.isEmpty {
                    print("message sent")
                }
            }
    }

    class func getTotalMessages(_ chatRoom:URChatRoom,completion:@escaping (Int)-> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(chatRoom.key!)
            .observeSingleEvent(of: .value, with: { snapshot -> Void in
                guard snapshot.value != nil else {
                    completion(0)
                    return
                }
                completion(Int(snapshot.childrenCount))
            })
    }
}
