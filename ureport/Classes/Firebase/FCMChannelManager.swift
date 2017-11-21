//
//  Manager.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import fcm_channel_ios

class FCMChannelManager {
    
    static let keyFCMToken = "KEY_FCM_TOKEN"
    
    static var apiPrefix = ""
    static var token = ""
    static var channel = ""
    static var handlerUrl = ""
    
    static func setup() {
        if let user = URUser.activeUser(),
            let userProgram = user.countryProgram,
            let userCountry = user.country,
            let dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Key", ofType: "plist")!) {
            
            setUpFCMChannel(dict: dict, userProgram: userProgram, userCountry: userCountry)
        }
        
        FCMChannelSettings.setConfiguration(token, channel: channel, url: apiPrefix, handlerURL: handlerUrl)
    }
    
    private static func setUpFCMChannel(dict: NSDictionary, userProgram: String, userCountry: String) {
        
        if let keyToken = dict["\(URConstant.Key.COUNTRY_PROGRAM_TOKEN)\(userProgram)"] {
            token = keyToken as! String
        }
        
        if let keyChannel = dict["\(URConstant.Key.COUNTRY_PROGRAM_CHANNEL)\(userProgram)"] {
            channel = keyChannel as! String
        }
        
        let countryProgram = URCountryProgramManager.getCountryProgramByCountry(URCountry(code: userCountry))
        apiPrefix = countryProgram.rapidProHostAPI
        handlerUrl = countryProgram.rapidProHostHandler
    }
    
    static func createContact(completion: @escaping (_ success: Bool) -> ()) {
        if let user = URUser.activeUser(),
            let key = user.key,
            let name = user.nickname,
            let fcmToken = user.pushIdentity {
            
           user.contact = FCMChannelContact(urn: key, name: name, fcmToken: fcmToken)
            RapidProAPI.registerContact(user.contact!) {
                uuid in
                
                if let uuid = uuid {
                    user.contact?.uuid = uuid
                    completion(true)
                } else {
                    print("Error: User couldn't register to channel.")
                    completion(false)
                }
            }
        }
    }
    
    static func loadContact(urn: String, completion: @escaping (FCMChannelContact?) -> ()) {
        RapidProAPI.loadContact(fromUrn: urn) {
            (contact) in
            
            completion(contact)
        }
    }
    
    static func saveFCMToken(fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: self.keyFCMToken)
    }
    
    static func getFCMToken() -> String? {
        return  UserDefaults.standard.value(forKey: self.keyFCMToken) as? String
    }
}
