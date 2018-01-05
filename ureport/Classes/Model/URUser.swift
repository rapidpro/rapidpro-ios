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

class URUser: Mappable {
    
    static let ref = URFireBaseManager.sharedInstance().child("users")
    
    var key: String!
    var nickname: String?
    var email: String?
    var state: String?
    var birthday: NSNumber?
    var language: String?
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
    
    init() { }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        key <- map["key"]
        nickname <- map["nickname"]
        email <- map["email"]
        state <- map["state"]
        birthday <- map["birthday"]
        language <- map["language"]
        country <- map["country"]
        picture <- map["picture"]
        gender <- map["gender"]
        type <- map["type"]
        countryProgram <- map["countryProgram"]
        chatRooms <- map["chatRooms"]
        contributions <- map["contributions"]
        points <- map["points"]
        stories <- map["stories"]
        polls <- map["polls"]
        pushIdentity <- map["pushIdentity"]
        publicProfile <- map["publicProfile"]
        born <- map["born"]
        district <- map["district"]
        moderator <- map["moderator"]
        masterModerator <- map["masterModerator"]
        socialUid <- map["socialUid"]
    }
    
    //MARK: User Account Manager
    
    static func activeUser() -> URUser? {
        var user: URUser?
        if let userString = UserDefaults.standard.getArchivedObject(key: "user") as? String { // let encodedData = encodedData, let string = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? String {
            user = URUser(JSONString: userString)
        }
        return user 
    }
    
    static func setActiveUser(_ user: URUser) {
        self.deactivateUser()
        UserDefaults.standard.setAsString(object: user, key: "user")
    }
    
    static func deactivateUser() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "user")
        defaults.synchronize()
    }
}
