//
//  URSettings.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URSettings: Serializable {

    var notifications:NSNumber?
    var chatNotifications:NSNumber?
    var availableInChat:NSNumber?
    var preferredLanguage:NSString?
    var firstRun:NSNumber?
    var reviewMode:NSNumber?
    
    class func saveSettingsLocaly(settings:URSettings) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(URSettings.buildSettingsValues(settings).toDictionary(), forKey: "settings")
        defaults.synchronize()
    }
    
    class func buildSettingsValues(settings:URSettings) -> URSettings{
        
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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let settingsDictionary = defaults.objectForKey("settings") as? NSDictionary {
            return URSettings(jsonDict:(settingsDictionary))
        }
        return URSettings();
    }
    
    class func checkIfTermsIsAccepted() -> Bool {
     
        if URSettings.getSettings().firstRun == nil {
            
            let termsViewController = URTermsViewController()
            
            termsViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            URNavigationManager.navigation!.presentViewController(termsViewController, animated: true) { () -> Void in
                UIView.animateWithDuration(0.3) { () -> Void in
                    termsViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
                }
            }
            
            return false
            
        }else{
            return true
        }
        
    }
    
}
