//
//  URUserManager.swift
//  ureport
//
//  Created by Daniel Amaral on 10/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

@objc protocol URUserManagerDelegate {
    @objc optional func newUserReceived(_ user:URUser)
}

class URUserManager: NSObject {
   
    var delegate:URUserManagerDelegate!
    
    //MARK: FireBase Methods
    class func path() -> String {
        return "user"
    }

    class func pathUserModerator() -> String {
        return "user_moderator"
    }
    
    class func reloadUserInfoWithCompletion(_ completion:@escaping (_ finish:Bool) -> Void) {
        if let user = URUser.activeUser() {
            URUserManager.getByKey(user.key, completion: { (userFromDB, exists) -> Void in
                if let userFromDB = userFromDB {
                    URUser.setActiveUser(userFromDB)
                    URUserLoginManager.setLoggedUser(userFromDB)
                    completion(true)
                }
            })
        }
    }
    
    class func save(_ user:URUser) {
            
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: user.key)
            .setValue(user.toDictionary())
        
        URUser.setActiveUser(user)
    }
    
    class func updatePushIdentity(_ user:URUser) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: user.key)
            .child(byAppendingPath: "pushIdentity")
            .setValue(user.pushIdentity)
        
        URUserLoginManager.setLoggedUser(user)

    }
    
    class func updateAvailableInChat(_ user:URUser,publicProfile:Bool) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: user.key)
            .child(byAppendingPath: "publicProfile")
            .setValue(publicProfile)
        
        URUserLoginManager.setLoggedUser(user)
        
    }
    
    class func setUserAsModerator(_ userKey:String) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URUserManager.pathUserModerator())
            .updateChildValues([userKey:true])
    }

    class func removeModerateUser(_ userKey:String) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URUserManager.pathUserModerator())
            .child(byAppendingPath: userKey)
            .removeValue()
    }
    
    class func updateChatroom(_ user:URUser,chatRoom:URChatRoom) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: user.key)
            .child(byAppendingPath: "chatRooms")
            .updateChildValues([chatRoom.key! : true])
    }
    
    class func removeChatroom(_ user:URUser,chatRoomKey:String) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URUserManager.path())
            .child(byAppendingPath: "chatRooms")
            .child(byAppendingPath: chatRoomKey)
            .removeValue { (error:Error?, firebase:Firebase?) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }else {
                    print("the user was removed from group")
                }
        }
    }
    
    func getUsersByPoints() {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URUserManager.path())
            .queryOrdered(byChild: "points")
            .observe(FEventType.childAdded, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    
                    if let delegate = self.delegate {                        
                        delegate.newUserReceived!(URUser(jsonDict: snapshot?.value as? NSDictionary))
                    }
                }else {
                    
                }
            })
    }
    
    class func getByKey(_ key:String,completion:@escaping (URUser?,Bool) -> Void){
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: key)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    
                    let user = URUser(jsonDict: (snapshot?.value as? NSDictionary))
                    
                    if let chatRooms = (snapshot?.value as? NSDictionary)?.object(forKey: "chatRooms") {
                        user.chatRooms = chatRooms as! NSDictionary
                    }
                    
                    completion(user,true)
                }else {
                    completion(nil,false)
                }
            })
    }
    
    class func checkIfUserIsMasterModerator(_ key:String,completion:@escaping (Bool) -> Void){
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URUserManager.pathUserModerator())
            .child(byAppendingPath: key)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in                
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    completion(true)
                }else {
                    completion(false)
                }
            })
    }
    
    class func checkIfUserIsCountryProgramModerator(_ key:String,completion:@escaping (Bool) -> Void){

        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URUserManager.pathUserModerator())
            .child(byAppendingPath: key)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in                
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    completion(true)
                }else {
                    completion(false)
                }
            })
    }
    
    
    class func getAllUserByCountryProgram(_ completion:@escaping ([URUser]?) -> Void){
        
        let countryProgram = URCountryProgramManager.activeCountryProgram()!.code!
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .queryOrdered(byChild: "countryProgram")
            .queryEqual(toValue: countryProgram)
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    
                    var userList:[URUser] = []
                    
                    for rest in snapshot?.children.allObjects as! [FDataSnapshot] {
                        let user = URUser(jsonDict: rest.value as? NSDictionary)
                        if user.publicProfile != nil && user.publicProfile!.boolValue == true && user.key != URUser.activeUser()!.key {
                            userList.append(user)
                        }
                    }
                    
                    completion(userList)
                }else {
                    completion(nil)
                }
            })
        
    }
    
    class func getAllModertorUsers(_ completion:@escaping ([String]?) -> Void){
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URCountryProgram.path())
            .child(byAppendingPath: URCountryProgramManager.activeCountryProgram()!.code)
            .child(byAppendingPath: URUserManager.pathUserModerator())
            .observeSingleEvent(of: FEventType.value, with: { snapshot in
                if ((snapshot != nil) && !(snapshot?.value is NSNull)) {
                    var userKeysList:[String] = []
                    for rest in snapshot?.children.allObjects as! [FDataSnapshot] {
                       userKeysList.append(rest.key)
                    }
                    
                    completion(userKeysList)
                    
                }else {
                    completion(nil)
                }
            })
        
    }
            
    class func incrementUserStories(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: userKey)
            .child(byAppendingPath: "stories")
            .runTransactionBlock { (currentData:FMutableData?) -> FTransactionResult! in
                
                var storiesCount = 1
                
                if currentData == nil || currentData?.value is NSNull{
                    currentData?.value = storiesCount
                }else{
                    storiesCount = currentData?.value as! Int + 1
                    currentData?.value = storiesCount
                }                
                
                URUserManager.incrementUserPointsUsingStoryCriteria(userKey)
                
                return FTransactionResult.success(withValue: currentData)
        }
    }
    
    class func incrementUserContributions(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: userKey)
            .child(byAppendingPath: "contributions")
            .runTransactionBlock { (currentData:FMutableData?) -> FTransactionResult! in
                
                var contributionsCount = 1
                
                if currentData == nil || currentData?.value is NSNull{
                    currentData?.value = contributionsCount
                }else{
                    contributionsCount = currentData?.value as! Int + 1
                    currentData?.value = contributionsCount
                }
                
                URUserManager.incrementUserPointsUsingContributionCriteria(userKey)
                
                return FTransactionResult.success(withValue: currentData)
        }
    }
    
    class func incrementUserPointsUsingStoryCriteria(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: userKey)
            .child(byAppendingPath: "points")
            .runTransactionBlock { (currentData:FMutableData?) -> FTransactionResult! in
                
                var pointsCount = URConstant.Gamefication.StoryPoints
                
                if currentData == nil || currentData?.value is NSNull{
                    currentData?.value = pointsCount
                }else{
                    pointsCount = currentData?.value as! Int + URConstant.Gamefication.StoryPoints
                    currentData?.value = pointsCount
                }
                
                let totalPoints = currentData?.value as! NSNumber
                
                let user = URUser.activeUser()
                user!.points = totalPoints
                
                URUser.setActiveUser(user)
                
                return FTransactionResult.success(withValue: currentData)
        }
    }
    
    class func incrementUserPointsUsingContributionCriteria(_ userKey:String){
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: userKey)
            .child(byAppendingPath: "points")
            .runTransactionBlock { (currentData:FMutableData?) -> FTransactionResult! in
                
                var pointsCount = URConstant.Gamefication.ContributionPoints
                
                if currentData == nil || currentData?.value is NSNull{
                    currentData?.value = pointsCount
                }else{
                    pointsCount = currentData?.value as! Int + URConstant.Gamefication.ContributionPoints
                    currentData?.value = pointsCount
                }
                
                let totalPoints = currentData?.value as! NSNumber
                
                let user = URUser.activeUser()
                user!.points = totalPoints
                
                URUser.setActiveUser(user)
                
                return FTransactionResult.success(withValue: currentData)
        }
    }
    
    class func fetchUser(_ user:URUser) {
        URUserManager.getByKey(user.key) { (user:URUser?, exists:Bool) -> Void in
            if user != nil {
                URUserLoginManager.setLoggedUser(user!)
            }
        }
    }

    class func fetchUserWithCompletion(_ user:URUser, completion:@escaping (URUser) -> Void) {
        URUserManager.getByKey(user.key) { (user:URUser?, exists:Bool) -> Void in
            if user != nil {
                URUserLoginManager.setLoggedUser(user!)
                completion(user!)
            }
        }
    }
    
    class func userHasPermissionToAccessTheFeature(_ featureNeedModeratorPermission:Bool) -> Bool {
        
        let user = URUser.activeUser()
        
        if user == nil {
            return true
        }
        
        if ( ((user!.masterModerator != nil) && (user!.masterModerator == true)) || ((user!.moderator != nil) &&
            (user!.moderator == true))) {
            return true
        }else if (featureNeedModeratorPermission == false){
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
             if URUser.activeUser()!.countryProgram == URCountryProgramManager.activeCountryProgram()?.code!{
                return true
            }else {
                return false
            }
        #endif
    }
    
}
