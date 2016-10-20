//
//  URSettings.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore

class URSettings: Serializable {
    
    var notifications:NSNumber?
    var chatNotifications:NSNumber?
    var availableInChat:NSNumber?
    var preferredLanguage:NSString?
    var firstRun:NSNumber?
    var reviewMode:NSNumber?
    
    class func saveSettingsLocaly(_ settings:URSettings) {
        let defaults = UserDefaults.standard
        defaults.set(URSettings.buildSettingsValues(settings).toDictionary(), forKey: "settings")
        defaults.synchronize()
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
        
        if settings.reviewMode == nil && savedSettings.reviewMode != nil{
            settings.reviewMode = savedSettings.reviewMode
        }
        
        return settings
    }
    
    class func getSettings() -> URSettings{
        
        let defaults = UserDefaults.standard
        
        if let settingsDictionary = defaults.object(forKey: "settings") as? NSDictionary {
            return URSettings(jsonDict:(settingsDictionary))
        }
        return URSettings();
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
