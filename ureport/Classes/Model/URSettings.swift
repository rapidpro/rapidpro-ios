//
//  URSettings.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URSettings: Serializable {

    var notifications:NSNumber!
    var chatNotifications:NSNumber!
    var availableInChat:NSNumber!
    
    class func saveSettingsLocaly(settings:URSettings) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(URSettings.buildSettingsValues(settings).toDictionary(), forKey: "settings")
        defaults.synchronize()
    }
    
    class func buildSettingsValues(settings:URSettings) -> URSettings{
        
        if let savedSettings = URSettings.getSettings() {
            
            if settings.notifications == nil && savedSettings.notifications != nil{
                settings.notifications = savedSettings.notifications
            }
            
            if settings.chatNotifications == nil && savedSettings.chatNotifications != nil{
                settings.chatNotifications = savedSettings.chatNotifications
            }
            
            if settings.availableInChat == nil && savedSettings.availableInChat != nil{
                settings.availableInChat = savedSettings.availableInChat
            }
            
        }
        return settings
    }
    
    class func getSettings() -> URSettings?{
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let settingsDictionary = defaults.objectForKey("settings") as? NSDictionary {
            return URSettings(jsonDict:(settingsDictionary))
        }
        return nil;
    }
    
}
