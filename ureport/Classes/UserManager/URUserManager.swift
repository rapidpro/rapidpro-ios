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
    optional func newUserReceived(user:URUser)
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
    
    class func save(user:URUser) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(user.key)
            .setValue(user.toDictionary())
        
        URUser.setActiveUser(user)
    }
    
    class func updatePushIdentity(user:URUser) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(user.key)
            .childByAppendingPath("pushIdentity")
            .setValue(user.pushIdentity)
        
        URUserLoginManager.setLoggedUser(user)

    }
    
    class func updateAvailableInChat(user:URUser,publicProfile:Bool) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(user.key)
            .childByAppendingPath("publicProfile")
            .setValue(publicProfile)
        
        URUserLoginManager.setLoggedUser(user)
        
    }
    
    class func setUserAsModerator(userKey:String) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URUserManager.pathUserModerator())
            .setValue([userKey:true])
    }

    class func removeModerateUser(userKey:String) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URUserManager.pathUserModerator())
            .childByAppendingPath(userKey)
            .removeValue()
    }
    
    class func updateChatroom(user:URUser,chatRoom:URChatRoom) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(user.key)
            .childByAppendingPath("chatRooms")
            .updateChildValues([chatRoom.key! : true])
    }
    
    class func removeChatroom(user:URUser,chatRoomKey:String) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URUserManager.path())
            .childByAppendingPath("chatRooms")
            .childByAppendingPath(chatRoomKey)
            .removeValueWithCompletionBlock { (error:NSError!, firebase:Firebase!) -> Void in
                if error != nil {
                    print(error.localizedDescription)
                }else {
                    print("the user was removed from group")
                }
        }
    }
    
    func getUsersByPoints() {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URUserManager.path())
            .queryOrderedByChild("points")
            .observeEventType(FEventType.ChildAdded, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    if let delegate = self.delegate {                        
                        delegate.newUserReceived!(URUser(jsonDict: snapshot.value as? NSDictionary))
                    }
                }else {
                    
                }
            })
    }
    
    class func getByKey(key:String,completion:(URUser?,Bool) -> Void){
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    let user = URUser(jsonDict: (snapshot.value as? NSDictionary))
                    
                    if let chatRooms = (snapshot.value as? NSDictionary)?.objectForKey("chatRooms") {
                        user.chatRooms = chatRooms as! NSDictionary
                    }
                    
                    completion(user,true)
                }else {
                    completion(nil,false)
                }
            })
    }
    
    class func checkIfUserIsMasterModerator(key:String,completion:(Bool) -> Void){
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URUserManager.pathUserModerator())
            .childByAppendingPath(key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in                
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    completion(true)
                }else {
                    completion(false)
                }
            })
    }
    
    class func checkIfUserIsCountryProgramModerator(key:String,completion:(Bool) -> Void){
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URUserManager.pathUserModerator())
            .childByAppendingPath(key)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in                
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    completion(true)
                }else {
                    completion(false)
                }
            })
    }
    
    
    class func getAllUserByCountryProgram(completion:([URUser]?) -> Void){
        
        let countryProgram = URCountryProgramManager.activeCountryProgram()!.code!
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .queryOrderedByChild("countryProgram")
            .queryEqualToValue(countryProgram)
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    
                    var userList:[URUser] = []
                    
                    for rest in snapshot.children.allObjects as! [FDataSnapshot] {
                        userList.append(URUser(jsonDict: rest.value as? NSDictionary))
                    }
                    
                    completion(userList)
                }else {
                    completion(nil)
                }
            })
        
    }
    
    class func getAllModertorUsers(completion:([String]?) -> Void){
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URCountryProgram.path())
            .childByAppendingPath(URCountryProgramManager.activeCountryProgram()!.code)
            .childByAppendingPath(URUserManager.pathUserModerator())
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                if ((snapshot != nil) && !(snapshot.value is NSNull)) {
                    var userKeysList:[String] = []
                    for rest in snapshot.children.allObjects as! [FDataSnapshot] {
                       userKeysList.append(rest.key)
                    }
                    
                    completion(userKeysList)
                    
                }else {
                    completion(nil)
                }
            })
        
    }
            
    class func incrementUserStories(userKey:String){
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(userKey)
            .childByAppendingPath("stories")
            .runTransactionBlock { (currentData:FMutableData!) -> FTransactionResult! in
                
                var storiesCount = 1
                
                if currentData == nil || currentData.value is NSNull{
                    currentData.value = storiesCount
                }else{
                    storiesCount = currentData.value as! Int + 1
                    currentData.value = storiesCount
                }                
                
                URUserManager.incrementUserPointsUsingStoryCriteria(userKey)
                
                return FTransactionResult.successWithValue(currentData)
        }
    }
    
    class func incrementUserContributions(userKey:String){
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(userKey)
            .childByAppendingPath("contributions")
            .runTransactionBlock { (currentData:FMutableData!) -> FTransactionResult! in
                
                var contributionsCount = 1
                
                if currentData == nil || currentData.value is NSNull{
                    currentData.value = contributionsCount
                }else{
                    contributionsCount = currentData.value as! Int + 1
                    currentData.value = contributionsCount
                }
                
                URUserManager.incrementUserPointsUsingContributionCriteria(userKey)
                
                return FTransactionResult.successWithValue(currentData)
        }
    }
    
    class func incrementUserPointsUsingStoryCriteria(userKey:String){
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(userKey)
            .childByAppendingPath("points")
            .runTransactionBlock { (currentData:FMutableData!) -> FTransactionResult! in
                
                var pointsCount = URConstant.Gamefication.StoryPoints
                
                if currentData == nil || currentData.value is NSNull{
                    currentData.value = pointsCount
                }else{
                    pointsCount = currentData.value as! Int + URConstant.Gamefication.StoryPoints
                    currentData.value = pointsCount
                }
                
                URUserManager.fetchUser(URUser.activeUser()!)
                return FTransactionResult.successWithValue(currentData)
        }
    }
    
    class func incrementUserPointsUsingContributionCriteria(userKey:String){
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(userKey)
            .childByAppendingPath("points")
            .runTransactionBlock { (currentData:FMutableData!) -> FTransactionResult! in
                
                var pointsCount = URConstant.Gamefication.ContributionPoints
                
                if currentData == nil || currentData.value is NSNull{
                    currentData.value = pointsCount
                }else{
                    pointsCount = currentData.value as! Int + URConstant.Gamefication.ContributionPoints
                    currentData.value = pointsCount
                }
                
                URUserManager.fetchUser(URUser.activeUser()!)                
                
                return FTransactionResult.successWithValue(currentData)
        }
    }
    
    class func fetchUser(user:URUser) {
        URUserManager.getByKey(user.key) { (user:URUser?, exists:Bool) -> Void in
            if user != nil {
                URUserLoginManager.setLoggedUser(user!)
            }
        }
    }

    class func fetchUserWithCompletion(user:URUser, completion:(URUser) -> Void) {
        URUserManager.getByKey(user.key) { (user:URUser?, exists:Bool) -> Void in
            if user != nil {
                URUserLoginManager.setLoggedUser(user!)
                completion(user!)
            }
        }
    }
    
    class func userHasPermissionToAccessTheFeature(featureNeedModeratorPermission:Bool) -> Bool {
        
        if URUser.activeUser() == nil {
            return true
        }
        
        if ( ((URUser.activeUser()!.masterModerator != nil) && (URUser.activeUser()?.masterModerator == true)) || ((URUser.activeUser()!.moderator != nil) &&
            (URUser.activeUser()!.moderator == true))) {
            return true
        }else if (featureNeedModeratorPermission == false){
            return URUserManager.isUserInYourOwnCountryProgram()
        }else {
            return false
        }
    }
    
    class func formatExtUserId(key:String) -> String {
        return key.stringByReplacingOccurrencesOfString(":", withString: "") .stringByReplacingOccurrencesOfString("-", withString: "")
    }
    
    class func isUserInYourOwnCountryProgram() -> Bool {
                
         if URUser.activeUser()!.countryProgram == URCountryProgramManager.activeCountryProgram()?.code!{
            return true
        }else {
            return false
        }
    }
    
}
