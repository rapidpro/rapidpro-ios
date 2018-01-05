//
//  URSettings.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore
import ObjectMapper

class URSettings: Mappable {
    
    var notifications:NSNumber?
    var chatNotifications:NSNumber?
    var availableInChat:NSNumber?
    var preferredLanguage:NSString?
    var firstRun:NSNumber?
    var reviewMode:NSNumber?
    
    init() {}
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        notifications <- map["notifications"]
        chatNotifications <- map["chatNotifications"]
        availableInChat <- map["availableInChat"]
        preferredLanguage <- map["preferredLanguage"]
        firstRun <- map["firstRun"]
        reviewMode <- map["reviewMode"]
    }
    
    class func saveSettingsLocaly(_ settings:URSettings) {
        UserDefaults.standard.setAsString(object: settings, key: "settings")
    }
    
    class func buildSettingsValues(_ settings:URSettings) -> URSettings{
        
        let savedSettings = URSettings.getSettings()
        
        if settings.notifications == nil && savedSettings.notifications != nil{
            settings.notifications = savedSettings.notifications
        }
        
        if settings.chatNotifications == nil && savedSettings.chatNotifications != nil{
            settings.chatNotifications = savedSettings.chatNotifications
        }
        
        if settings.availableInChat == nil && savedSettings.availableInChat != nil{
            settings.availableInChat = savedSettings.availableInChat
        }
        
        if settings.preferredLanguage == nil && savedSettings.preferredLanguage != nil{
            settings.preferredLanguage = savedSettings.preferredLanguage
        }
        
        if settings.firstRun == nil && savedSettings.firstRun != nil{
            settings.firstRun = savedSettings.firstRun
        }
        
        if settings.reviewMode == nil && savedSettings.reviewMode != nil {
            settings.reviewMode = savedSettings.reviewMode
        }
        
        return settings
    }
    
    class func getSettings() -> URSettings {
        var settings: URSettings?
        if let settingsString = UserDefaults.standard.getArchivedObject(key: "settings") as? String {
            settings = URSettings(JSONString: settingsString)
        }
        
        return settings ?? URSettings()
    }
    
    class func checkIfTermsIsAccepted(_ termsViewController:ISTermsViewController,viewController:UIViewController) -> Bool {
        
        if URSettings.getSettings().firstRun == nil {
            
            if let viewController = viewController as? URLoginViewController {
                termsViewController.delegate = viewController
            }else if let viewController = viewController as? URUserRegisterViewController {
                termsViewController.delegate = viewController
            }
            
            termsViewController.show(true, inViewController: viewController)
            
            return false
            
        }else{
            return true
        }
        
    }
    
}
