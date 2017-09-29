//
//  URFCMManager.swift
//  ureport
//
//  Created by Rubens Pessoa on 27/09/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import Foundation
import UIKit
import fcm_channel_ios
import Firebase

class URFCMManager {
    
    static let keyFCMToken = "KEY_FCM_TOKEN"
    
    static var apiPrefix = ""
    static var token = ""
    static var channel = ""
    static var handlerUrl = ""
    
    static func setupPush() {
        var rootDictionary: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Key-debug", ofType: "plist") {
            rootDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = rootDictionary {
            if dict["COUNTRY_PROGRAM_TOKEN_SANDBOX"] != nil {
                token = dict["COUNTRY_PROGRAM_TOKEN_SANDBOX"] as! String
            }
            
            if dict["COUNTRY_PROGRAM_CHANNEL_SANDBOX"] != nil {
                channel = dict["COUNTRY_PROGRAM_CHANNEL_SANDBOX"] as! String
            }
            
            if dict["API_PREFIX"] != nil {
                apiPrefix = dict["API_PREFIX"] as! String
            }
            
            if dict["HANDLER_URL"] != nil {
                handlerUrl = dict["HANDLER_URL"] as! String
            }
        }
        
        ISPushSettings.setConfiguration(token, channel: channel, url: apiPrefix, handlerURL: handlerUrl)
    }
    
    static func createPushContact(completion: @escaping (_ success: Bool, _ contact: ISPushContact?) -> ()) {
        if let urn = URUser.activeUser()?.socialUid, let name = URUser.activeUser()?.nickname, let pushIdentity = URUser.activeUser()?.pushIdentity {
            var contact = ISPushContact(urn: urn, name: name, pushIdentity: pushIdentity)
            
            ISPushManager.registerContact(contact) {
                uuid in
                
                if uuid != nil {
                    contact.uuid = uuid
                    completion(true, contact)
                } else {
                    print("Error: User couldn't register to channel.")
                    completion(false, nil)
                }
            }
        }
    }
    
    static func loadPushContact(urn: String, completion: @escaping (ISPushContact?) -> ()) {
        ISPushManager.loadContact(fromUrn: urn) {
            (pushContact) in
            
            completion(pushContact)
        }
    }
    
    static func saveFCMToken(fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: self.keyFCMToken)
    }
    
    static func getFCMToken() -> String? {
        return  UserDefaults.standard.value(forKey: self.keyFCMToken) as? String
    }
}
