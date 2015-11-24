//
//  URConstants.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

struct URConstant {
   
    static let keyPath = NSBundle.mainBundle().pathForResource("Key", ofType: "plist")
    static let keyDictionary = NSDictionary(contentsOfFile: URConstant.keyPath!)
    
    struct Color {
        static let PRIMARY = UIColor(rgba: "#42b6e7")
        static let PRIMARY_DARK = UIColor(rgba: "#3aadda")
        static let DARK_BLUE = UIColor(rgba: "#5398C7")
        static let TRANSLUCENT_COVER = UIColor(rgba: "#6000")
        static let WINDOW_BACKGROUND = UIColor(rgba: "#e1e1e1")
        static let YELLOW = UIColor(rgba: "#ebce2c")
        static let HIGHLIGHT = UIColor(rgba: "#ec2248")
        static let BUTTON = UIColor(rgba: "#e8e8e8")
        static let BUTTON_PRESSED = UIColor(rgba: "#c0c0c0")
        static let LINE = UIColor(rgba: "#44c9c9c9")
        static let LINE_STRONG = UIColor(rgba: "#d7d7d7")
        static let LOGIN_PRIMARY = UIColor(rgba: "#00d755")
        static let LOGIN_PRIMARY_DARK = UIColor(rgba: "#00cd4e")
        static let SIGNUP_PRIMARY = UIColor(rgba: "#ffcc01")
        static let SIGNUP_PRIMARY_DARK = UIColor(rgba: "#f7bb01")
        static let CONFIRM_INFO_PRIMARY = UIColor(rgba: "#01d1db")
        static let CONFIRM_INFO_PRIMARY_DARK = UIColor(rgba: "#00bbc2")
    }

    struct Gamefication {
        static let StoryPoints = 5
        static let PollPoints = 5
        static let ContributionPoints = 1
    }
    
    struct SocialNetwork {
        
        static func TWITTER_APP_ID() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["TWITTER_APP_ID"] != nil {
                    return dictionary["TWITTER_APP_ID"] as! String
                }else{
                    print("TWITTER_APP_ID doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func FACEBOOK_APP_ID() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["FACEBOOK_APP_ID"] != nil {
                    return dictionary["FACEBOOK_APP_ID"] as! String
                }else{
                    print("FACEBOOK_APP_ID doesn't exists in key.plist")
                }
            }
            return ""
        }
    }
    
    struct AWS {
        
        static func COGNITO_IDENTITY_POLL_ID() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["COGNITO_IDENTITY_POLL_ID"] != nil {
                    return dictionary["COGNITO_IDENTITY_POLL_ID"] as! String
                }else{
                    print("COGNITO_IDENTITY_POLL_ID doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func S3_BUCKET_NAME(path:URUploadPath) -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["S3_BUCKET_NAME_\(path.rawValue)"] != nil {
                    return dictionary["S3_BUCKET_NAME_\(path.rawValue)"] as! String
                }else{
                    print("S3_BUCKET_NAME doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func URL_STORAGE(path:URUploadPath) -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["URL_STORAGE_\(path.rawValue)"] != nil {
                    print(dictionary["URL_STORAGE_\(path.rawValue)"])
                    return dictionary["URL_STORAGE_\(path.rawValue)"] as! String
                }else{
                    print("URL_STORAGE doesn't exists in key.plist")
                }
            }
            return ""
        }

    }
    
    struct Media {
        static let VIDEO = "Video"
        static let PICTURE = "Picture"
    }
    
    struct Youtube {
        static let COVERIMAGE = "http://img.youtube.com/vi/%@/mqdefault.jpg"
    }
    
    struct RapidPro {
        static let GLOBAL = "GLOBAL"
        static let API_URL = "https://api.rapidpro.io/api/v1/"
        static let API_NEWS = "http://ureport.in/api/v1/stories/org/"
    }
    
    struct Key {
        static let COUNTRY_PROGRAM_CHANNEL = "COUNTRY_PROGRAM_CHANNEL_"
        static let COUNTRY_PROGRAM_TOKEN = "COUNTRY_PROGRAM_TOKEN_"
    }
    
}
