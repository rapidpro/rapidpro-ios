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
    func newMessageReceived(chatMessage:URChatMessage)
}


class URChatMessageManager: NSObject {
    
    var delegate:URChatMessageManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_messages"
    }
    
    func getMessages(chatRoom:URChatRoom) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(URChatMessageManager.path())
            .childByAppendingPath(chatRoom.key)
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let chatMessage = URChatMessage()
                    
                    chatMessage.user = URUser(jsonDict: snapshot.value.objectForKey("user") as? NSDictionary)
                    chatMessage.message = snapshot.value.objectForKey("message") as? String
                    chatMessage.media = URMedia(jsonDict:snapshot.value.objectForKey("media") as? NSDictionary)
                    chatMessage.date = snapshot.value.objectForKey("date") as! NSNumber
                    
                    if chatMessage.user.nickname != nil {
                        delegate.newMessageReceived(chatMessage)
                    }
                }
            })
    }
    
    class func getLastMessage(key:String,completion:(URChatMessage?) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(key)
            .queryLimitedToLast(1)
            .observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot:FDataSnapshot!) -> Void in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    completion(URChatMessage(jsonDict:((snapshot.children.allObjects[0] as! FDataSnapshot).value as? NSDictionary)))
                }else {
                    completion(nil)
                }
            })
    }
    
    class func sendChatMessage(chatMessage:URChatMessage, chatRoom:URChatRoom) {
        URGCMManager.notifyChatMessage(chatRoom, chatMessage: chatMessage)
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(chatRoom.key)
            .childByAutoId()
            .setValue(chatMessage.toDictionary(), withCompletionBlock: { (error:NSError!, firebase:Firebase!) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else if !(firebase!.key.isEmpty) {
                    print("message sent")
                }
                
            })
    }
    
    class func getTotalMessages(chatRoom:URChatRoom,completion:(Int)-> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(chatRoom.key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot:FDataSnapshot!) -> Void in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    completion(Int(snapshot.childrenCount))
                }else {
                    completion(0)
                }
            })
    }
    
}
