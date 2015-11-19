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
    func newMemberInChatRoom(user:URUser)
}

class URChatMemberManager: NSObject {
   
    var delegate:URChatMemberManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_members"
    }
    
    class func save(chatMember:URChatMember, user:URUser?, completion:(Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(chatMember.key)
            .childByAppendingPath(user!.key)
            .setValue(true, withCompletionBlock: { (error:NSError?, firebase:Firebase?) -> Void in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            })
        
    }
    
    class func getByKey(key:String,completion:(FDataSnapshot?,Bool) -> Void){
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    completion(snapshot,true)
                }else {
                    completion(nil,false)
                }
            })
    }
    
    func getByChatRoom(key:String){
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(URChatMemberManager.path())
            .childByAppendingPath(key)
            .observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    if let delegate = self.delegate {
                        
                        URUserManager.getByKey(snapshot.key, completion: { (user:URUser?, exists:Bool) -> Void in
                            if exists == true && user != nil {
                                delegate.newMemberInChatRoom(user!)
                            }
                        })
                        
                    }
                }else {
                    
                }
            })
    }
    
    class func removeMemberByChatRoomKey(memberKey:String,chatRoomKey:String) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(URChatMemberManager.path())
            .childByAppendingPath(chatRoomKey)
            .childByAppendingPath(memberKey)
            .removeValueWithCompletionBlock { (error:NSError!, firebase:Firebase!) -> Void in                
                if error != nil {
                    print(error.localizedDescription)
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
    
    class func removeChatRoom(memberKey:String,chatRoomKey:String) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(URChatMemberManager.path())
            .childByAppendingPath(chatRoomKey)
            .removeValueWithCompletionBlock { (error:NSError!, firebase:Firebase!) -> Void in
                if error != nil {
                    print(error.localizedDescription)
                }else {
                    
                    print("removed chatroom from chatMember")
                    
                    URUserManager.getByKey(memberKey, completion: { (user, exists) -> Void in
                        if user != nil {
                            URUserManager.removeChatroom(user!, chatRoomKey: chatRoomKey)
                        }
                    })
                    
                    URFireBaseManager.sharedInstance()
                        .childByAppendingPath(URCountryProgram.path())
                        .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
                        .childByAppendingPath(URChatMessageManager.path())
                        .childByAppendingPath(chatRoomKey)
                        .removeValueWithCompletionBlock { (error:NSError!, firebase:Firebase!) -> Void in
                            if error != nil {
                                print(error.localizedDescription)
                            }else {
                                print("removed chatroom from chatMessage")
                            }
                            
                    }
                    
                    URFireBaseManager.sharedInstance()
                        .childByAppendingPath(URCountryProgram.path())
                        .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
                        .childByAppendingPath(URChatRoomManager.path())
                        .childByAppendingPath(chatRoomKey)
                        .removeValueWithCompletionBlock { (error:NSError!, firebase:Firebase!) -> Void in
                            if error != nil {
                                print(error.localizedDescription)
                            }else {
                                print("removed chatroom")
                            }
                    }
                    
                }
        }
        
    }
    
    class func getChatMembersByChatRoomWithCompletion(key:String,completionWithUsers:([URUser]) -> Void){
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    var listMembers:[URUser] = []
                    let total = Int(snapshot.childrenCount)
                    
                    for data in snapshot.children.allObjects as! [FDataSnapshot]{
                        
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
