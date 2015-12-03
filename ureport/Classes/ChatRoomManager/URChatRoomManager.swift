//
//  URChatRoomManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import Firebase

@objc protocol URChatRoomManagerDelegate {
    optional func newOpenGroupReceived(groupChatRoom:URGroupChatRoom)
}

class URChatRoomManager: NSObject {
    
    var delegate:URChatRoomManagerDelegate?
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "chat_room"
    }
    
    class func createIndividualChatRoomIfPossible(user:URUser) {
        if let chatRooms = user.chatRooms {
            for chatRoomKey in chatRooms.allKeys {
                
                let filtered = user.chatRooms.filter {
                    return $0.key as! String == chatRoomKey as! String
                }
                
                if !filtered.isEmpty {
                    URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoomKey as! String, completionWithUsers: { (users:[URUser]) -> Void in
                        URChatRoomManager.getByKey(chatRoomKey as! String, completion: { (chatRoom) -> Void in
                            URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:users,title:user.nickname),animated:true)
                        })
                    })
                }else {
                    ProgressHUD.show(nil)
                    URChatRoomManager.createIndividualChatRoom(user, completion: { (chatRoom, chatMembers, title) -> Void in
                        ProgressHUD.dismiss()
                        URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:chatMembers,title:title),animated:true)
                    })
                }
                
            }
        }else {
            ProgressHUD.show(nil)
            URChatRoomManager.createIndividualChatRoom(user, completion: { (chatRoom, chatMembers, title) -> Void in
                ProgressHUD.dismiss()
                URNavigationManager.navigation.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:chatMembers,title:title),animated:true)
            })
        }
        
    }
    
    class func getByKey(key:String,completion:(URChatRoom?) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()?.code)
            .childByAppendingPath(path())
            .childByAppendingPath(key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    if (snapshot.value as! NSDictionary).objectForKey("administrator") != nil {
                        
                        let administrator = URUser(jsonDict: (snapshot.value as! NSDictionary).objectForKey("administrator") as? NSDictionary)
                        let picture = URMedia(jsonDict: (snapshot.value as! NSDictionary).objectForKey("picture") as? NSDictionary)
                        let groupChatRoom = URGroupChatRoom(jsonDict: snapshot.value as? NSDictionary)
                        
                        groupChatRoom.createdDate = (snapshot.value as! NSDictionary).objectForKey("createdDate") as! NSNumber
                        groupChatRoom.administrator = administrator
                        groupChatRoom.picture = picture
                        
                        completion(groupChatRoom)
                        
                    }else {
                        let individualChatRoom = URIndividualChatRoom(jsonDict: (snapshot.value as! NSDictionary))
                        individualChatRoom.key = snapshot.key
                        completion(individualChatRoom)
                    }
                }else {
                    completion(nil)
                }
            })
    }
    
    class func createIndividualChatRoom(user:URUser,completion:(chatRoom:URChatRoom,chatMembers:[URUser],title:String) -> Void) {
        let chatRoom:URChatRoom = URChatRoom()
        chatRoom.type = "Individual"
        chatRoom.createdDate = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
        
        ProgressHUD.show(nil)
        URChatRoomManager.save(chatRoom, members: [user,URUser.activeUser()!]) { (chatRoom:URChatRoom?) -> Void in
            if chatRoom != nil{
                ProgressHUD.show(nil)
                URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom!.key, completionWithUsers: { (users) -> Void in
                    ProgressHUD.dismiss()
                    completion(chatRoom: chatRoom!,chatMembers:users,title:user.nickname)
                })
            }
        }
    }
    
    class func save(chatRoom:URChatRoom, members:[URUser], completion:(URChatRoom) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.path())
            .childByAutoId()
            .setValue(chatRoom.toDictionary(), withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else if !(firebase!.key.isEmpty) {
                    
                    let chatMembers:URChatMember = URChatMember(key:firebase.key)
                    chatRoom.key = chatMembers.key
                    
                    for user in members {
                        
                        URChatMemberManager.save(chatMembers, user: user, completion: { (success) -> Void in
                            if success == true {
                                URGCMManager.registerUserInTopic(user, chatRoom: chatRoom)
                                URUserManager.updateChatroom(user, chatRoom: chatRoom)
                            }
                        })
                    }
                    
                    completion(chatRoom)
                    
                }
            })
    }
    
    class func update(chatRoom:URChatRoom, newMembers:[URUser], completion:(URChatRoom) -> Void) {    
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(self.path())
            .childByAppendingPath(chatRoom.key)
            .setValue(chatRoom.toDictionary(), withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else {

                    URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key, completionWithUsers: { (members) -> Void in
                        for user in members {
                            URChatMemberManager.removeMemberByChatRoomKey(user.key, chatRoomKey: chatRoom.key)
                        }
                        
                        let chatMember = URChatMember(key:chatRoom.key)
                        
                        for user in newMembers {
                            
                            URChatMemberManager.save(chatMember, user: user, completion: { (success) -> Void in
                                if success == true {
                                    URGCMManager.registerUserInTopic(user, chatRoom: chatRoom)
                                    URUserManager.updateChatroom(user, chatRoom: chatRoom)
                                }
                            })
                        }
                        completion(chatRoom)                                                            
                    })
                }
            })
    }
    
    func getOpenGroups() {
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URChatRoomManager.path())
            .queryOrderedByChild("privateAccess")
            .queryEqualToValue(false)
            .observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
                if let delegate = self.delegate {
                    
                    let group = URGroupChatRoom(jsonDict: (snapshot.value as! NSDictionary))
                    let administrator = URUser(jsonDict: (snapshot.value as! NSDictionary).objectForKey("administrator") as? NSDictionary)
                    
                    if let picture = (snapshot.value as! NSDictionary).objectForKey("picture") as? NSDictionary{
                        group.picture = URMedia(jsonDict: picture)
                    }
                    
                    group.administrator = administrator
                    group.key = snapshot.key
                    
                    URChatMemberManager.getByKey(group.key, completion: { (data, exists) -> Void in
                        if exists == true{
                            for object in data!.children {
                                let userKey = (object as! FDataSnapshot).key
                                if userKey == URUser.activeUser()!.key {
                                    group.userIsMember = true
                                }
                            }
                            
                            delegate.newOpenGroupReceived!(group)
                        }
                    })
                }
            })
        
    }
    
    class func getChatRooms(user:URUser,completion:([URChatRoom]?) -> Void){
        
        var chatRoomList:[URChatRoom] = []
        var totalChatRooms = 0
        var currentChatRoom = 0
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URUserManager.path())
            .childByAppendingPath(user.key)
            .childByAppendingPath("chatRooms")
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    totalChatRooms = snapshot.children.allObjects.count
                    
                    for rest in snapshot.children.allObjects as! [FDataSnapshot] {
                        currentChatRoom++
                        
                        URChatMemberManager.getByKey(rest.key, completion: { (snapshot:FDataSnapshot?, exists:Bool) -> Void in
                            if exists == true && snapshot?.childrenCount > 0 {
                                if snapshot?.childrenCount > 2 {
                                    //GroupChat                                    
                                    URChatRoomManager.getByKey(rest.key, completion: { (chatRoom:URChatRoom?) -> Void in
                                        
                                        if chatRoom == nil {
                                            return
                                        }
                                        
                                        chatRoom!.key = rest.key

                                        URChatMessageManager.getLastMessage(rest.key, completion: { (chatMessage:URChatMessage?) -> Void in
                                            if chatMessage != nil {
                                                chatRoom!.lastMessage = chatMessage
                                                
                                                URChatMessageManager.getTotalMessages(chatRoom!, completion: { (totalMessages:Int) -> Void in
                                                    var totalUnreadMessages = 0
                                                    
                                                    for messageRead in URMessageRead.getMessagesRead() as [NSDictionary]{
                                                        let messageRead = URMessageRead(jsonDict:messageRead)
                                                        if messageRead.roomKey == chatRoom!.key {
                                                            totalUnreadMessages = totalMessages - Int(messageRead.totalMessages)
                                                        }
                                                    }
                                                    
                                                    chatRoom!.totalUnreadMessages = totalUnreadMessages
                                                    
                                                    chatRoomList.append(chatRoom!)
                                                    
                                                    if currentChatRoom == totalChatRooms {
                                                        completion(chatRoomList)
                                                    }
                                                    
                                                })
                                                
                                            }else{
                                                chatRoomList.append(chatRoom!)
                                                if currentChatRoom == totalChatRooms {
                                                    completion(chatRoomList)
                                                }
                                            }
                                            
                                        })
                                    })
                                    
                                } else if snapshot?.childrenCount == 2 {
                                    //IndividualChat
                                    var userKey:String = ""
                                    
                                    if ((snapshot!.children.allObjects[0] as! FDataSnapshot).key != user.key){
                                        userKey = (snapshot!.children.allObjects[0] as! FDataSnapshot).key
                                    } else {
                                        userKey = (snapshot!.children.allObjects[1] as! FDataSnapshot).key
                                    }
                                    
                                    URUserManager.getByKey(userKey, completion: { (user:URUser?, exists:Bool) -> Void in
                                        if exists == true && user != nil {
                                            
                                            let individualChatRoom:URIndividualChatRoom = URIndividualChatRoom()
                                            individualChatRoom.friend = user!
                                            individualChatRoom.key = rest.key
                                            
                                            URChatMessageManager.getLastMessage(rest.key, completion: { (chatMessage:URChatMessage?) -> Void in
                                                if chatMessage != nil {
                                                    individualChatRoom.lastMessage = chatMessage
                                                    
                                                    URChatMessageManager.getTotalMessages(individualChatRoom, completion: { (totalMessages:Int) -> Void in
                                                        var totalUnreadMessages = 0
                                                        
                                                        for messageRead in URMessageRead.getMessagesRead() as [NSDictionary]{
                                                            let messageRead = URMessageRead(jsonDict:messageRead)
                                                            if messageRead.roomKey == individualChatRoom.key {
                                                                totalUnreadMessages = totalMessages - Int(messageRead.totalMessages)
                                                            }
                                                        }
                                                        
                                                        individualChatRoom.totalUnreadMessages = totalUnreadMessages
                                                        
                                                        chatRoomList.append(individualChatRoom)
                                                        
                                                        if currentChatRoom == totalChatRooms {
                                                            completion(chatRoomList)
                                                        }
                                                        
                                                    })
                                                    
                                                }else{
                                                    chatRoomList.append(individualChatRoom)
                                                    if currentChatRoom == totalChatRooms {
                                                        completion(chatRoomList)
                                                    }
                                                }
                                                
                                            })
                                            
                                        }
                                    })
                                    
                                }
                                
                                completion(chatRoomList)
                                
                            }
                        })
                        
                    }
                }else {
                    completion(nil)
                }
            })
        
    }
    
}
