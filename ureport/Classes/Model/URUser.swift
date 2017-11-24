//
//  URUser.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseDatabase
import fcm_channel_ios

class URUser: Serializable {
    
    static let ref = URFireBaseManager.sharedInstance().child("users")
    
    var key: String!
    var nickname: String?
    var email: String?
    var state: String?
    var birthday: NSNumber?
    var country: String?
    var picture: String?
    var gender: String?
    var type: String?
    var countryProgram: String?
    var chatRooms:NSDictionary?
    var contributions:NSNumber?
    var points:NSNumber?
    var stories:NSNumber?
    var polls:NSNumber?
    var pushIdentity:String?
    var publicProfile:NSNumber?
    var born:String?
    var district:String?
    var moderator:NSNumber?
    var masterModerator:NSNumber?
    var socialUid:String?

    override init() {
        super.init()
    }
    
    //MARK: User Account Manager
    
    static func activeUser() -> URUser? {
        let defaults: UserDefaults = UserDefaults.standard
        var encodedData: Data?
        
        encodedData = defaults.object(forKey: "user") as? Data
        
        if encodedData != nil {
            let user: URUser = URUser(jsonDict: NSKeyedUnarchiver.unarchiveObject(with: encodedData!) as? NSDictionary)
            return user
        } else{
            return nil
        }
        
    }
    
    static func setActiveUser(_ user: URUser) {
        self.deactivateUser()
        let defaults: UserDefaults = UserDefaults.standard
        let userDict = user.toDictionary()
        let encodedObject: Data = NSKeyedArchiver.archivedData(withRootObject: userDict)
        defaults.set(encodedObject, forKey: "user")
        defaults.synchronize()
    }
    
    static func deactivateUser() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "user")
        defaults.synchronize()
    }
}
