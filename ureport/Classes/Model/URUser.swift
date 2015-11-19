//
//  URUser.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URUser: Serializable {
    
    var key: String!
    var nickname: String!
    var email: String!
    var state: String!
    var birthday: NSNumber!
    var country: String!
    var picture: String!
    var gender: String!
    var type: String!
    var countryProgram: String!
    var chatRooms:NSDictionary!
    var contributions:NSNumber!
    var points:NSNumber!
    var stories:NSNumber!
    var polls:NSNumber!
    var pushIdentity:String!
    var publicProfile:NSNumber!
    var born:String!
    var district:String!
    var moderator:NSNumber!
    var masterModerator:NSNumber!
    
    override init() {
        super.init()
    }
    
    //MARK: User Account Manager
    
    static func activeUser() -> URUser? {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var encodedData: NSData?
        
        encodedData = defaults.objectForKey("user") as? NSData
        
        if encodedData != nil {
            let user: URUser = URUser(jsonDict: NSKeyedUnarchiver.unarchiveObjectWithData(encodedData!) as? NSDictionary)
            return user
        }else{
            return nil
        }
        
    }
    
    static func setActiveUser(user: URUser!) {
        self.deactivateUser()
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let encodedObject: NSData = NSKeyedArchiver.archivedDataWithRootObject(user.toDictionary())
        defaults.setObject(encodedObject, forKey: "user")
        defaults.synchronize()
    }
    
    static func deactivateUser() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("user")
        defaults.synchronize()
    }

}
