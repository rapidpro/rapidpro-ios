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

class URChatMemberManager: NSObject {
   
    var delegate:URChatMemberManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_members"
    }
    
    class func save(_ chatMember:URChatMember, user:URUser?, completion:@escaping (Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: chatMember.key)
            .child(byAppendingPath: user!.key)
            .setValue(true, withCompletionBlock: { (error:Error?, firebase:Firebase?) -> Void in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            })
        
    }
    
    class func getByKey(_ key:String,completion:@escaping (FDataSnapshot?,Bool) -> Void){
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: key)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    completion(snapshot,true)
                }else {
                    completion(nil,false)
                }
            })
    }
    
    func getByChatRoom(_ key:String){
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: URChatMemberManager.path())
            .child(byAppendingPath: key)
            .observe(FEventType.childAdded, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    
                    if let delegate = self.delegate {
                        
                        URUserManager.getByKey((snapshot?.key)!, completion: { (user:URUser?, exists:Bool) -> Void in
                            if exists == true && user != nil {
                                delegate.newMemberInChatRoom(user!)
                            }
                        })
                        
                    }
                }else {
                    
                }
            })
    }
    
    class func removeMemberByChatRoomKey(_ memberKey:String,chatRoomKey:String) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: URChatMemberManager.path())
            .child(byAppendingPath: chatRoomKey)
            .child(byAppendingPath: memberKey)
            .removeValue { (error:Error?, firebase:Firebase?) -> Void in                
                if error != nil {
                    print(error?.localizedDescription)
                }else {
                    print("the user was removed from group")
                    
                    URUserManager.getByKey(memberKey, completion: { (user, exists) -> Void in
                        if user != nil {
                            URUserManager.removeChatroom(user!, chatRoomKey: chatRoomKey)
                        }
                    })
                    
                }
        }
        
    }
    
    class func removeChatRoom(_ memberKey:String,chatRoomKey:String) {
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
            .child(byAppendingPath: URChatMemberManager.path())
            .child(byAppendingPath: chatRoomKey)
            .removeValue { (error:Error?, firebase:Firebase?) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else {
                    
                    print("removed chatroom from chatMember")
                    
                    URUserManager.getByKey(memberKey, completion: { (user, exists) -> Void in
                        if user != nil {
                            URUserManager.removeChatroom(user!, chatRoomKey: chatRoomKey)
                        }
                    })
                    
                    URFireBaseManager.sharedInstance()
                        .child(byAppendingPath: URCountryProgram.path())
                        .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
                        .child(byAppendingPath: URChatMessageManager.path())
                        .child(byAppendingPath: chatRoomKey)
                        .removeValue { (error:Error?, firebase:Firebase?) -> Void in
                            if let error = error {
                                print(error.localizedDescription)
                            }else {
                                print("removed chatroom from chatMessage")
                            }
                            
                    }
                    
                    URFireBaseManager.sharedInstance()
                        .child(byAppendingPath: URCountryProgram.path())
                        .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()?.code)
                        .child(byAppendingPath: URChatRoomManager.path())
                        .child(byAppendingPath: chatRoomKey)
                        .removeValue { (error:Error?, firebase:Firebase?) -> Void in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("removed chatroom")
                            }
                    }
                    
                }
        }
        
    }
    
    class func getChatMembersByChatRoomWithCompletion(_ key:String,completionWithUsers:@escaping ([URUser]) -> Void){
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: key)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    var listMembers:[URUser] = []
                    let total = Int((snapshot?.childrenCount)!)
                    
                    for data in snapshot?.children.allObjects as! [FDataSnapshot]{
                        
                        URUserManager.getByKey(data.key, completion: { (user:URUser?, exists:Bool) -> Void in
                            if exists == true && user != nil {

                                listMembers.append(user!)

                                if total == listMembers.count {
                                    
                                    completionWithUsers(listMembers)
                                }
                            }
                        })
                    }
                    
                }else {
                    
                }
            })
    }
        
}
