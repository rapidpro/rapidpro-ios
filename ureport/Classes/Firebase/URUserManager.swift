//
//  URUserManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

protocol URUserManagerDelegate {
    func newUserReceived(_ user:URUser)
}

class URUserManager {

    var delegate: URUserManagerDelegate!

    static var path: String = "user"

    //MARK: FireBase Methods

    class func pathUserModerator() -> String {
        return "user_moderator"
    }

    class func reloadUserInfoWithCompletion(_ completion: @escaping (_ finish: Bool) -> Void) {
        if let user = URUser.activeUser() {
            URUserManager.getByKey(user.key, completion: { (userFromDB, exists) -> Void in
                guard let userFromDB = userFromDB else { return }
                URUser.setActiveUser(userFromDB)
                URUserLoginManager.setLoggedUser(userFromDB) {
                    completion(true)
                }
            })
        } else {
            completion(false)
        }
    }

    class func save(_ user:URUser) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(user.key)
            .setValue(user.toJSON())
        URUser.setActiveUser(user)
    }

    class func updatePushIdentity(_ user:URUser, completion: @escaping (_ success: Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(user.key)
            .child("pushIdentity")
            .setValue(user.pushIdentity, withCompletionBlock: { (error, dbRerference) in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        URUserLoginManager.setLoggedUser(user) {}
    }

    class func updateAvailableInChat(_ user:URUser,publicProfile:Bool) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(user.key)
            .child("publicProfile")
            .setValue(publicProfile)
        URUserLoginManager.setLoggedUser(user) {}
    }

    class func setUserAsModerator(_ userKey:String) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URUserManager.pathUserModerator())
            .updateChildValues([userKey:true])
    }

    class func removeModerateUser(_ userKey:String) {
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URUserManager.pathUserModerator())
            .child(userKey)
            .removeValue()
    }

    class func getChatRooms(_ user:URUser, completion: @escaping (_ chatRoomKeys: [String]?) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(user.key)
            .child("chatRooms").observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.hasChildren() else {
                    completion(nil)
                    return
                }
                var chatRoomKeys: [String] = []
                for chatRoomNode in snapshot.children.allObjects as! [DataSnapshot] {
                    chatRoomKeys.append(chatRoomNode.key)
                }
                completion(chatRoomKeys)
            })
    }

    class func updateChatroom(_ user:URUser,chatRoom:URChatRoom) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(user.key)
            .child("chatRooms")
            .updateChildValues([chatRoom.key! : true])
    }

    class func removeChatroom(_ user:URUser,chatRoomKey:String) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child("chatRooms")
            .child(chatRoomKey)
            .removeValue { (error: Error?, firebase: DatabaseReference?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }else {
                    print("the user was removed from group")
                }
        }
    }

    func getUsersByPoints() {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .queryOrdered(byChild: "points")
            .observe(.childAdded, with: { snapshot in
                
                guard let user = URUser(snapshot: snapshot), self.delegate != nil else { return }
                self.delegate.newUserReceived(user)
            })
    }

    class func getByKey(_ key:String, completion:@escaping (URUser?, Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(key)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let user = URUser(snapshot: snapshot) else {
                    completion(nil, false)
                    return
                }

                completion(user, true)
            })
    }
    
    class func getByKeys(_ keys: Set<String>, completion:@escaping ([String: URUser]?) -> Void) {
        guard keys.count > 0 else {
            completion([:])
            return
        }
        
        var counter = 0
        
        var keysAndUsers = [String: URUser]()
        for key in keys {
            URFireBaseManager.sharedInstance()
                .child(URUserManager.path)
                .child(key)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    if let user = URUser(snapshot: snapshot) {
                        keysAndUsers[user.key] = user
                    }
                    
                    counter += 1
                    if counter == keys.count {
                        completion(keysAndUsers)
                        return
                    }
                })
        }
    }
    
    class func checkIfUserIsMasterModerator(_ key:String,completion:@escaping (Bool) -> Void){
        URFireBaseManager.sharedInstance()
            .child(URUserManager.pathUserModerator())
            .child(key)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.value is NSNull {
                    completion(false)
                } else {
                    completion(true)
                }
            })
    }

    class func checkIfUserIsCountryProgramModerator(_ key:String,completion:@escaping (Bool) -> Void){
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URUserManager.pathUserModerator())
            .child(key)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.value is NSNull {
                    completion(false)
                } else {
                    completion(true)
                }
            })
    }

    class func getAllUserByCountryProgram(_ completion:@escaping ([URUser]?) -> Void){
        let countryProgram = URCountryProgramManager.activeCountryProgram()!.code
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .queryOrdered(byChild: "countryProgram")
            .queryEqual(toValue: countryProgram)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion(nil)
                    return
                }
                var userList:[URUser] = []
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    if let user = URUser(snapshot: rest), user.publicProfile != nil && user.publicProfile!.boolValue == true && user.key != URUser.activeUser()!.key {
                        userList.append(user)
                    }
                }
                completion(userList)
            })
    }

    class func getAllModertorUsers(_ completion:@escaping ([String]?) -> Void){
        URFireBaseManager.sharedInstance()
            .child(URCountryProgram.path())
            .child(URCountryProgramManager.activeCountryProgram()!.code)
            .child(URUserManager.pathUserModerator())
            .observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.value != nil else {
                    completion(nil)
                    return
                }
                var userKeysList:[String] = []
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    userKeysList.append(rest.key)
                }
                completion(userKeysList)
            })
    }

    class func incrementUserStories(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(userKey)
            .child("stories")
            .runTransactionBlock { currentData -> TransactionResult in
                var storiesCount = 1
                if let value = currentData.value as? Int {
                    storiesCount = value + 1
                    currentData.value = storiesCount
                } else {
                    currentData.value = storiesCount
                }
                URUserManager.incrementUserPointsUsingStoryCriteria(userKey)
                return TransactionResult.success(withValue: currentData)
        }
    }

    class func incrementUserContributions(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(userKey)
            .child("contributions")
            .runTransactionBlock { currentData -> TransactionResult in
                var contributionsCount = 1
                if let value = currentData.value as? Int {
                    contributionsCount = value + 1
                    currentData.value = contributionsCount
                } else {
                    currentData.value = contributionsCount
                }
                URUserManager.incrementUserPointsUsingContributionCriteria(userKey)
                return TransactionResult.success(withValue: currentData)
        }
    }

    class func incrementUserPointsUsingStoryCriteria(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(userKey)
            .child("points")
            .runTransactionBlock { currentData -> TransactionResult in
                var pointsCount = URConstant.Gamefication.StoryPoints
                if let value = currentData.value as? Int {
                    pointsCount = value + URConstant.Gamefication.StoryPoints
                    currentData.value = pointsCount
                } else {
                    currentData.value = pointsCount
                }
                let totalPoints = currentData.value as! NSNumber
                let user = URUser.activeUser()
                user!.points = totalPoints
                URUser.setActiveUser(user!)
                return TransactionResult.success(withValue: currentData)
        }
    }

    class func incrementUserPointsUsingContributionCriteria(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(URUserManager.path)
            .child(userKey)
            .child("points")
            .runTransactionBlock { currentData ->  TransactionResult in
                var pointsCount = URConstant.Gamefication.ContributionPoints
                if let value = currentData.value as? Int {
                    pointsCount = value + URConstant.Gamefication.ContributionPoints
                    currentData.value = pointsCount
                } else {
                    currentData.value = pointsCount
                }
                let totalPoints = currentData.value as! NSNumber
                let user = URUser.activeUser()
                user!.points = totalPoints
                URUser.setActiveUser(user!)
                return TransactionResult.success(withValue: currentData)
        }
    }

    class func fetchUser(_ user:URUser) {
        URUserManager.getByKey(user.key) { (user, exists) -> Void in
            guard let user = user else { return }
            URUserLoginManager.setLoggedUser(user) {}
        }
    }

    class func fetchUserWithCompletion(_ user:URUser, completion:@escaping (URUser) -> Void) {
        URUserManager.getByKey(user.key) { (user, exists) -> Void in
            guard let user = user else { return }
            URUserLoginManager.setLoggedUser(user) {}
            completion(user)
        }
    }

    class func userHasPermissionToAccessTheFeature(_ featureNeedModeratorPermission:Bool) -> Bool {
        guard let user = URUser.activeUser() else { return true }
        if ((user.masterModerator != nil && user.masterModerator == true) || (user.moderator != nil && user.moderator == true)) {
            return true
        } else if !featureNeedModeratorPermission {
            return URUserManager.isUserInYourOwnCountryProgram()
        } else {
            return false
        }
    }

    class func formatExtUserId(_ key:String) -> String {
        return key.replacingOccurrences(of: ":", with: "") .replacingOccurrences(of: "-", with: "")
    }

    class func isUserInYourOwnCountryProgram() -> Bool {
        #if ONTHEMOVE
            return true
        #else
            if URUser.activeUser()!.countryProgram == URCountryProgramManager.activeCountryProgram()?.code {
                return true
            } else {
                return false
            }
        #endif
    }
    
    class func hasModeratorPrivilegies() -> Bool {
        var userIsModerator = false
        
        if let isMasterModerator = URUser.activeUser()?.masterModerator {
            userIsModerator = isMasterModerator.boolValue
        } else if let isCountryModerator = URUser.activeUser()?.moderator {
            userIsModerator = isCountryModerator.boolValue
        }
        
        return userIsModerator
    }
    
}
