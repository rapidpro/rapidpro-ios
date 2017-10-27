//
//  URConstants.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

struct URConstant {
    
    static let keyPath = Bundle.main.path(forResource: URFireBaseManager.Properties, ofType: "plist")
    static let keyDictionary = NSDictionary(contentsOfFile: URConstant.keyPath!)
    
    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    
    #if ONTHEMOVE
    struct Color {
        static let PRIMARY = UIColor(rgba: "#8750A0")
        static let PRIMARY_DARK = UIColor(rgba: "#6d4081")
        static let DARK_BLUE = UIColor(rgba: "#5a366b")
        static let TRANSLUCENT_COVER = UIColor(rgba: "#6000")
        static let WINDOW_BACKGROUND = UIColor(rgba: "#e1e1e1")
        static let YELLOW = UIColor(rgba: "#ebce2c")
        static let HIGHLIGHT = UIColor(rgba: "#ec2248")
        static let BUTTON = UIColor(rgba: "#e8e8e8")
        static let BUTTON_PRESSED = UIColor(rgba: "#c0c0c0")
        static let LINE = UIColor(rgba: "#44c9c9c9")
        static let LINE_STRONG = UIColor(rgba: "#d7d7d7")
        static let LOGIN_PRIMARY = UIColor(rgba: "#8750A0")
        static let LOGIN_PRIMARY_DARK = UIColor(rgba: "#6d4081")
        static let SIGNUP_PRIMARY = UIColor(rgba: "#8750A0")
        static let SIGNUP_PRIMARY_DARK = UIColor(rgba: "#6d4081")
        static let CONFIRM_INFO_PRIMARY = UIColor(rgba: "#8750A0")
        static let CONFIRM_INFO_PRIMARY_DARK = UIColor(rgba: "#6d4081")
        static let MEDIA_CAMERA = UIColor(rgba: "#16B1F0")
        static let MEDIA_GALLERY = UIColor(rgba: "#FFBB42")
        static let MEDIA_VIDEOPHONE = UIColor(rgba: "#B438CE")
        static let MEDIA_FILE = UIColor(rgba: "#FA741A")
        static let MEDIA_AUDIO = UIColor(rgba: "#1CD355")
        static let MEDIA_YOUTUBE = UIColor(rgba: "#F13A41")
    }
    #else
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
        static let MEDIA_CAMERA = UIColor(rgba: "#16B1F0")
        static let MEDIA_GALLERY = UIColor(rgba: "#FFBB42")
        static let MEDIA_VIDEOPHONE = UIColor(rgba: "#B438CE")
        static let MEDIA_FILE = UIColor(rgba: "#FA741A")
        static let MEDIA_AUDIO = UIColor(rgba: "#1CD355")
        static let MEDIA_YOUTUBE = UIColor(rgba: "#F13A41")
    }
    #endif
    
    struct Gamefication {
        static let StoryPoints = 5
        static let PollPoints = 5
        static let ContributionPoints = 1
    }
    
    struct Auth {
        
        static func AUTH_LOGIN() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["AUTH_LOGIN"] != nil {
                    return dictionary["AUTH_LOGIN"] as! String
                }else{
                    print("AUTH_LOGIN doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func AUTH_FACEBOOK() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["AUTH_FACEBOOK"] != nil {
                    return dictionary["AUTH_FACEBOOK"] as! String
                }else{
                    print("AUTH_FACEBOOK doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func AUTH_GOOGLE() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["AUTH_GOOGLE"] != nil {
                    return dictionary["AUTH_GOOGLE"] as! String
                }else{
                    print("AUTH_GOOGLE doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func AUTH_TWITTER() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["AUTH_TWITTER"] != nil {
                    return dictionary["AUTH_TWITTER"] as! String
                }else{
                    print("AUTH_TWITTER doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func AUTH_REGISTER() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["AUTH_REGISTER"] != nil {
                    return dictionary["AUTH_REGISTER"] as! String
                }else{
                    print("AUTH_REGISTER doesn't exists in key.plist")
                }
            }
            return ""
        }
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
        
        static func TWITTER_CONSUMER_SECRET() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["TWITTER_CONSUMER_SECRET"] != nil {
                    return dictionary["TWITTER_CONSUMER_SECRET"] as! String
                }else{
                    print("TWITTER_CONSUMER_SECRET doesn't exists in key.plist")
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
        
        static func ACCESS_KEY() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["S3_BUCKET_ACCESS_KEY"] != nil {
                    return dictionary["S3_BUCKET_ACCESS_KEY"] as! String
                }else{
                    print("S3_BUCKET_ACCESS_KEY doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func ACCESS_SECRET() -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["S3_BUCKET_ACCESS_SECRET"] != nil {
                    return dictionary["S3_BUCKET_ACCESS_SECRET"] as! String
                }else{
                    print("S3_BUCKET_ACCESS_SECRET doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func S3_BUCKET_NAME(_ path:URUploadPath) -> String {
            
            if let dictionary = keyDictionary {
                if dictionary["S3_BUCKET_NAME_\(path.rawValue)"] != nil {
                    return dictionary["S3_BUCKET_NAME_\(path.rawValue)"] as! String
                }else{
                    print("S3_BUCKET_NAME doesn't exists in key.plist")
                }
            }
            return ""
        }
        
        static func URL_STORAGE(_ path:URUploadPath) -> String {
            
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
        static let FILE = "File"
        static let AUDIO = "Audio"
        static let VIDEOPHONE = "VideoPhone"
        static let VIDEO = "Video"
        static let PICTURE = "Picture"
    }
    
    struct Youtube {
        static let COVERIMAGE = "http://img.youtube.com/vi/%@/mqdefault.jpg"
    }
    
    struct RapidPro {
        static let GLOBAL = "GLOBAL"
        static let API_URL = "https://api.rapidpro.io/api/"
        static let API_NEWS = "http://ureport.in/api/v1/stories/org/"
        static let API_URL_ILHA = "https://rapidpro.ilhasoft.mobi/api/"
    }
    
    struct NotificationType {
        static let RAPIDPRO = "Rapidpro"
        static let CHAT = "Chat"
    }
    
    struct Gcm {
        static let GCM_URL = "https://gcm-http.googleapis.com/gcm/send"
        static let GCM_AUTHORIZATION = "key=AIzaSyAUwf0ZOqn9BXA6lhupxKmTcEpv_tYdoVs"
    }
    
    struct Key {
        static let COUNTRY_PROGRAM_CHANNEL = "COUNTRY_PROGRAM_CHANNEL_"
        static let COUNTRY_PROGRAM_TOKEN = "COUNTRY_PROGRAM_TOKEN_"
    }
    
}
