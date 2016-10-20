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


class URChatMessageManager: NSObject {
    
    var delegate:URChatMessageManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_messages"
    }
    
    func getMessages(_ chatRoom:URChatRoom) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: URChatMessageManager.path())
            .child(byAppendingPath: chatRoom.key)
            .observe(FEventType.childAdded, with: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let chatMessage = URChatMessage()
                    
                    chatMessage.user = URUser(jsonDict: (snapshot?.value as AnyObject).object(forKey: "user") as? NSDictionary)
                    chatMessage.message = (snapshot?.value as AnyObject).object(forKey: "message") as? String
                    chatMessage.media = URMedia(jsonDict:(snapshot?.value as AnyObject).object(forKey: "media") as? NSDictionary)
                    chatMessage.date = (snapshot?.value as AnyObject).object(forKey: "date") as! NSNumber
                    
                    print(snapshot?.childrenCount)
                    
                    if chatMessage.user.nickname != nil {
                        delegate.newMessageReceived(chatMessage)
                    }
                }
            })
    }
    
    class func getLastMessage(_ key:String,completion:@escaping (URChatMessage?) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: key)
            .queryLimited(toLast: 1)
            .observeSingleEvent(of: FEventType.value, with: { (snapshot:FDataSnapshot?) -> Void in
                if ((snapshot != nil) && !(snapshot!.value is NSNull)) {
                    completion(URChatMessage(jsonDict:((snapshot!.children.allObjects[0] as! FDataSnapshot).value as? NSDictionary)))
                }else {
                    completion(nil)
                }
            })
    }
    
    class func sendChatMessage(_ chatMessage:URChatMessage, chatRoom:URChatRoom) {
        URGCMManager.notifyChatMessage(chatRoom, chatMessage: chatMessage)
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: chatRoom.key)
            .childByAutoId()
            .setValue(chatMessage.toDictionary(), withCompletionBlock: { (error:Error?, firebase:Firebase?) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else if !(firebase!.key.isEmpty) {
                    print("message sent")
                }
                
            })
    }
    
    class func getTotalMessages(_ chatRoom:URChatRoom,completion:@escaping (Int)-> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: chatRoom.key)
            .observeSingleEvent(of: FEventType.value, with: { (snapshot:FDataSnapshot?) -> Void in
                if ((snapshot != nil) && !(snapshot!.value is NSNull)) {
                    completion(Int(snapshot!.childrenCount))
                }else {
                    completion(0)
                }
            })
    }
    
}
