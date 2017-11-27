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
            let userCountry = user.country {
            
            setUpFCMChannel(userProgram: userProgram, userCountry: userCountry)
        }
        
        FCMChannelSettings.setConfiguration(token, channel: channel, url: apiPrefix, handlerURL: handlerUrl)
    }
    
    static func activeContact() -> FCMChannelContact? {
        let defaults: UserDefaults = UserDefaults.standard

        var contact: FCMChannelContact?
        if let encodedData = defaults.object(forKey: "fcmchannelcontact") as? Data,
            let jsonString =  NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? String {
            contact = FCMChannelContact(JSONString: jsonString)
        }
        return contact
    }
    
    static func deactivateChannelContact() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: "fcmchannelcontact")
        defaults.synchronize()
    }
    
    private static func setUpFCMChannel(userProgram: String, userCountry: String) {
        if let keyToken = URCountryProgramManager.getToken(for: userProgram)  {
            token = keyToken
        }
        
        if let keyChannel = URCountryProgramManager.getChannelToken(for: userProgram) {
            channel = keyChannel
        }
        
        let countryProgram = URCountryProgramManager.getCountryProgramByCountry(URCountry(code: userCountry))
        apiPrefix = countryProgram.rapidProHostAPI
        handlerUrl = countryProgram.rapidProHostHandler
    }
    
    static func createContactAndSave(for user: URUser, completion: @escaping (_ contact: FCMChannelContact?) -> ()) {
        if let key = user.key, let name = user.nickname, let fcmToken = user.pushIdentity {
            self.deactivateChannelContact()

            let contact = FCMChannelContact(urn: key, name: name, fcmToken: fcmToken)
            RapidProAPI.registerContact(contact) {
                uuid in
                if let uuid = uuid {
                    contact.uuid = uuid
                    let defaults: UserDefaults = UserDefaults.standard
                    let encodedObject: Data = NSKeyedArchiver.archivedData(withRootObject: contact.toJSONString())
                    defaults.set(encodedObject, forKey: "fcmchannelcontact")
                    defaults.synchronize()
                    
                    completion(contact)
                } else {
                    print("Error: User couldn't register to channel.")
                    completion(nil)
                }
            }
        } else {
            completion(nil)
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
