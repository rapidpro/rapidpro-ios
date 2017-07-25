//
//  URChatRoomManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import Firebase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

@objc protocol URChatRoomManagerDelegate {
    @objc optional func newOpenGroupReceived(_ groupChatRoom:URGroupChatRoom)
    @objc optional func openChatRoom(_ chatRoom:URChatRoom, members:[URUser], title:String)
}

class URChatRoomManager {

    var delegate:URChatRoomManagerDelegate?
    static var path = "chat_room"

    //MARK: FireBase Methods

    func createIndividualChatRoomIfPossible(_ friend:URUser,isIndividualChatRoom:Bool) {
        
        let group = DispatchGroup()
        
        var equalsChatRoomKeyList = [String]()
        var equalsChatRoomList = [URChatRoom]()
        var equalsGroupChatRoomList = [URChatRoom]()
        
        let friendChatRooms = friend.chatRooms
        let myChatRooms = URUser.activeUser()?.chatRooms
        
        //return
        
        if friendChatRooms != nil && myChatRooms != nil {
            
            for friendChatRoomKey in friendChatRooms!.allKeys {
                for myChatRoomKey in myChatRooms!.allKeys {
                    
                    if myChatRoomKey as! String == friendChatRoomKey as! String {
                        equalsChatRoomKeyList.append(myChatRoomKey as! String)
                    }
                    
                }
            }
            
            for chatRoomKey in equalsChatRoomKeyList {
                group.enter()
                URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoomKey, completionWithUsers: { (users:[URUser]) -> Void in
                    URChatRoomManager.getByKey(chatRoomKey, completion: { (chatRoom:URChatRoom?) -> Void in
                        
                        chatRoom!.key = chatRoomKey
                        
                        if chatRoom?.type == URChatRoomType.Group {
                            equalsGroupChatRoomList.append(chatRoom!)
                        }else {
                            equalsChatRoomList.append(chatRoom!)
                        }
                        group.leave()
                    })
                    
                })
                
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                
                if equalsChatRoomList.count > 0 {
                    self.delegate?.openChatRoom!(equalsChatRoomList[0],members:[URUser.activeUser()!,friend],title:friend.nickname!)
                }else {
                    URChatRoomManager.createIndividualChatRoom(friend, completion: { (chatRoom, chatMembers, title) -> Void in
                        self.delegate?.openChatRoom!(chatRoom,members:chatMembers,title:title)
                        
                    })
                }
                
            })
            
        }else {
            URChatRoomManager.createIndividualChatRoom(friend, completion: { (chatRoom, chatMembers, title) -> Void in
                self.delegate?.openChatRoom!(chatRoom,members:chatMembers,title:title)
                
            })
        }
        
    }
    
    class func getByKey(_ key:String,completion:@escaping (URChatRoom?) -> Void) {
        
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()?.code ?? "")
            .child(URChatRoomManager.path)
            .child(key)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion(nil)
                    return
                }
                if (snapshot.value as! NSDictionary).object(forKey: "administrator") != nil {

                    let administrator = URUser(jsonDict: (snapshot.value as! NSDictionary).object(forKey: "administrator") as? NSDictionary)
                    let picture = URMedia(jsonDict: (snapshot.value as! NSDictionary).object(forKey: "picture") as? NSDictionary)
                    let groupChatRoom = URGroupChatRoom(jsonDict: snapshot.value as? NSDictionary)

                    groupChatRoom.createdDate = (snapshot.value as! NSDictionary).object(forKey: "createdDate") as! NSNumber
                    groupChatRoom.administrator = administrator
                    groupChatRoom.picture = picture
                    groupChatRoom.type = URChatRoomType.Group
                    groupChatRoom.key = snapshot.key

                    completion(groupChatRoom)

                } else {
                    let individualChatRoom = URIndividualChatRoom(jsonDict: (snapshot.value as! NSDictionary))
                    individualChatRoom.key = snapshot.key
                    individualChatRoom.type = URChatRoomType.Individual

                    completion(individualChatRoom)
                }
            })
    }
    
    class func createIndividualChatRoom(_ user:URUser,completion:@escaping (_ chatRoom: URChatRoom,_ chatMembers: [URUser],_ title: String) -> Void) {
        let chatRoom:URChatRoom = URChatRoom()
        chatRoom.type = "Individual"
        chatRoom.createdDate = NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64)
        
        URChatRoomManager.save(chatRoom, members: [user,URUser.activeUser()!]) { (chatRoom:URChatRoom?) -> Void in
            if chatRoom != nil{
                URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom!.key!, completionWithUsers: { (users) -> Void in
                    completion(chatRoom!, users, user.nickname!)
                })
            }
        }
    }

    class func save(_ chatRoom:URChatRoom, members:[URUser], completion: @escaping (URChatRoom) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatRoomManager.path)
            .childByAutoId()
            .setValue(chatRoom.toDictionary(), withCompletionBlock: { (error, dbReference) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                if !dbReference.key.isEmpty {
                    let chatMembers:URChatMember = URChatMember(key:dbReference.key)
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

    class func update(_ chatRoom:URChatRoom, newMembers:[URUser], completion:@escaping (URChatRoom) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatRoomManager.path)
            .child(chatRoom.key!)
            .setValue(chatRoom.toDictionary(), withCompletionBlock: { (error, firebase) -> Void in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key!, completionWithUsers: { members -> Void in
                    for user in members {
                        URChatMemberManager.removeMemberByChatRoomKey(user.key, chatRoomKey: chatRoom.key!)
                    }

                    let chatMember = URChatMember(key:chatRoom.key!)

                    for user in newMembers {

                        URChatMemberManager.save(chatMember, user: user, completion: { (success) -> Void in
                            if success {
                                URGCMManager.registerUserInTopic(user, chatRoom: chatRoom)
                                URUserManager.updateChatroom(user, chatRoom: chatRoom)
                            }
                        })
                    }
                    completion(chatRoom)
                })
            })
    }
    
    func getOpenGroups() {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatRoomManager.path)
            .queryOrdered(byChild: "privateAccess")
            .queryEqual(toValue: false)
            .observe(.childAdded, with: { snapshot in
                guard let delegate = self.delegate else { return }

                let group = URGroupChatRoom(jsonDict: (snapshot.value as! NSDictionary))
                let administrator = URUser(jsonDict: (snapshot.value as! NSDictionary).object(forKey: "administrator") as? NSDictionary)

                if let picture = (snapshot.value as! NSDictionary).object(forKey: "picture") as? NSDictionary{
                    group.picture = URMedia(jsonDict: picture)
                }
                group.administrator = administrator
                group.key = snapshot.key
                group.type = URChatRoomType.Group
                URChatMemberManager.getByKey(group.key!, completion: { (data, exists) -> Void in
                    guard exists == true else { return }
                    for object in data!.children {
                        let userKey = (object as! DataSnapshot).key
                        if userKey == URUser.activeUser()!.key {
                            group.userIsMember = true
                        }
                    }
                    delegate.newOpenGroupReceived!(group)
                })
            })
    }
    
    class func blockUser(_ chatRoomKey:String) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatRoomManager.path)
            .child(chatRoomKey)
            .updateChildValues(["blocked" : URUser.activeUser()!.key])
    }
    
    class func unblockUser(_ chatRoomKey:String) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URChatRoomManager.path)
            .child(chatRoomKey)
            .child("blocked")
            .removeValue()
    }
    
    class func getChatRooms(_ user:URUser,completion:@escaping ([URChatRoom]?) -> Void){
        
        var chatRoomList:[URChatRoom] = []
        
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(user.key)
            .child("chatRooms")
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion(nil)
                    return
                }
                for rest in snapshot.children.allObjects as! [DataSnapshot] {

                    URChatMemberManager.getByKey(rest.key, completion: { (snapshot, exists) -> Void in
                        if exists && snapshot?.childrenCount > 0 {
                            if snapshot?.childrenCount > 2 {
                                //GroupChat
                                URChatRoomManager.getByKey(rest.key, completion: { chatRoom -> Void in
                                    guard let chatRoom = chatRoom else {
                                        return
                                    }
                                    chatRoom.key = rest.key
                                    URChatMessageManager.getLastMessage(rest.key, completion: { chatMessage -> Void in
                                        guard let chatMessage = chatMessage else {
                                            chatRoomList.append(chatRoom)
                                            completion(chatRoomList)
                                            return
                                        }
                                        chatRoom.lastMessage = chatMessage
                                        URChatMessageManager.getTotalMessages(chatRoom, completion: { totalMessages -> Void in
                                            var totalUnreadMessages = 0

                                            for messageRead in URMessageRead.getMessagesRead() as [NSDictionary]{
                                                let messageRead = URMessageRead(jsonDict:messageRead)
                                                if messageRead.roomKey == chatRoom.key {
                                                    totalUnreadMessages = totalMessages - Int(messageRead.totalMessages)
                                                }
                                            }

                                            chatRoom.totalUnreadMessages = totalUnreadMessages
                                            chatRoomList.append(chatRoom)
                                            completion(chatRoomList)
                                        })
                                    })
                                })
                            } else if snapshot?.childrenCount == 2 {
                                //IndividualChat
                                var userKey = ""
                                if ((snapshot!.children.allObjects[0] as! DataSnapshot).key != user.key) {
                                    userKey = (snapshot!.children.allObjects[0] as! DataSnapshot).key
                                } else {
                                    userKey = (snapshot!.children.allObjects[1] as! DataSnapshot).key
                                }
                                URUserManager.getByKey(userKey, completion: { (user, exist) -> Void in
                                    if user != nil && exists {
                                        URChatRoomManager.getByKey(rest.key, completion: { chatRoom -> Void in
                                            if chatRoom is URIndividualChatRoom {
                                                let individualChatRoom = chatRoom as! URIndividualChatRoom
                                                individualChatRoom.friend = user!
                                                URChatMessageManager.getLastMessage(rest.key, completion: { chatMessage -> Void in
                                                    guard let chatMessage = chatMessage else {
                                                        chatRoomList.append(individualChatRoom)
                                                        completion(chatRoomList)
                                                        return
                                                    }
                                                    individualChatRoom.lastMessage = chatMessage
                                                    URChatMessageManager.getTotalMessages(individualChatRoom, completion: { totalMessages -> Void in
                                                        var totalUnreadMessages = 0
                                                        for messageRead in URMessageRead.getMessagesRead() as [NSDictionary] {
                                                            let messageRead = URMessageRead(jsonDict:messageRead)
                                                            if messageRead.roomKey == individualChatRoom.key {
                                                                totalUnreadMessages = totalMessages - Int(messageRead.totalMessages)
                                                            }
                                                        }
                                                        individualChatRoom.totalUnreadMessages = totalUnreadMessages
                                                        chatRoomList.append(individualChatRoom)
                                                        completion(chatRoomList)
                                                    })
                                                })

                                            }

                                        })
                                    }
                                })
                            }
                        }
                    })
                }
            })
        
    }
    
}
