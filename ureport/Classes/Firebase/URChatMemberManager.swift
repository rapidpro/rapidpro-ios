//
//  URChatMemberManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

protocol URChatMemberManagerDelegate {
    func newMemberInChatRoom(_ user:URUser)
}

class URChatMemberManager {
   
    var delegate:URChatMemberManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_members"
    }
    
    class func save(_ chatMember:URChatMember, user:URUser?, completion:@escaping (Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(chatMember.key!)
            .child(user!.key)
            .setValue(true) { (error, _) -> Void in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }

    }
    
    class func getByKey(_ key: String, completion: @escaping (DataSnapshot?, Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(key)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion(nil, false)
                    return
                }
                completion(snapshot, true)
            })
    }
    
    func getByChatRoom(_ key:String){
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatMemberManager.path())
            .child(key)
            .observe(.childAdded, with: { snapshot in
                guard snapshot.value != nil else {
                    return
                }
                if let delegate = self.delegate {
                    URUserManager.getByKey(snapshot.key) { (user, exists) -> Void in
                        if user != nil && exists {
                            delegate.newMemberInChatRoom(user!)
                        }
                    }
                }
            })
    }
    
    class func removeMemberByChatRoomKey(_ memberKey:String,chatRoomKey:String) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatMemberManager.path())
            .child(chatRoomKey)
            .child(memberKey)
            .removeValue { (error, _) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                print("the user was removed from group")
                URUserManager.getByKey(memberKey, completion: { (user, exists) -> Void in
                    if let user = user {
                        URUserManager.removeChatroom(user, chatRoomKey: chatRoomKey)
                    }
                })
        }
        
    }
    
    class func removeChatRoom(_ memberKey:String, chatRoomKey:String) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatMemberManager.path())
            .child(chatRoomKey)
            .removeValue { (error, _) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                print("removed chatroom from chatMember")

                URUserManager.getByKey(memberKey) { (user, exists) -> Void in
                    if user != nil {
                        URUserManager.removeChatroom(user!, chatRoomKey: chatRoomKey)
                    }
                }

                URFireBaseManager.sharedInstance()
                    .child(URCountryProgram.path())
                    .child(URCountryProgramManager.activeCountryProgram()!.code)
                    .child(URChatMessageManager.path())
                    .child(chatRoomKey)
                    .removeValue { (error, _) -> Void in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        print("removed chatroom from chatMessage")
                    }

                URFireBaseManager.sharedInstance()
                    .child(URCountryProgram.path())
                    .child(URCountryProgramManager.activeCountryProgram()!.code)
                    .child(URChatRoomManager.path)
                    .child(chatRoomKey)
                    .removeValue { (error, _) -> Void in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        print("removed chatroom")
                }
        }
        
    }
    
    class func getChatMembersByChatRoomWithCompletion(_ key:String, completionWithUsers: @escaping ([URUser]) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(self.path())
            .child(key)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    return
                }
                var listMembers:[URUser] = []
                let total = Int(snapshot.childrenCount)

                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    URUserManager.getByKey(data.key) { (user, exists) -> Void in
                        if user != nil && exists {
                            listMembers.append(user!)
                            if total == listMembers.count {
                                completionWithUsers(listMembers)
                            }
                        }
                    }
                }
            })
    }
        
}
