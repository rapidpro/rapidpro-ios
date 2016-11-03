//
//  URFireBaseManager.swift
//  ureport
//
//  Created by Daniel Amaral on 17/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

enum URFireBaseManagerAuthError {
    case invalidEmail
    case invalidUser
}

class URFireBaseManager: NSObject {
    
    static let Properties = "Key"
//    static let Properties = "Key-debug"
    static let Path = "https://u-report.firebaseio.com/"
//    static let Path = "https://u-report-dev.firebaseio.com/"
//    static let Path = "https://u-report-beta.firebaseio.com"
    
    static let GCM_DEBUG_MODE = true
    
//    Production
///    static let region = AWSRegionType.euWest1
//    Debug
    static let region = AWSRegionType.usEast1

//    Production
//        static let credentialsProvider:AWSCredentialsProvider = AWSStaticCredentialsProvider(accessKey: URConstant.AWS.ACCESS_KEY(), secretKey: URConstant.AWS.ACCESS_SECRET())
//    Debug
    static let credentialsProvider:AWSCredentialsProvider = AWSCognitoCredentialsProvider(regionType: region, identityPoolId: URConstant.AWS.COGNITO_IDENTITY_POLL_ID())
    
    static let Reference = Firebase(url: Path)
    
    static func sharedInstance() -> Firebase {
        
        if let countryCode = URIPCheckManager.countryCode , countryCode == URIPCheckManager.syriaCountryCode {
            return Firebase(url: "http://ureport-socket.ilhasoft.mobi:5000")
             
        }else {
            return Reference!
        }
    }
    
    static func sharedLoginInstance() -> Firebase {
        let reference = Firebase(url: "https://ureport-proxy.ilhasoft.mobi/v2/u-report/auth")
        return reference!
        //return Reference!
    }
    
    static func authUserWithPassword(email:String,password:String, completion:@escaping (_ user:URUser?,_ authError:URFireBaseManagerAuthError?) -> Void) -> Void {
        Alamofire.request(String(format: URConstant.Auth.AUTH_LOGIN(), email,password)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let uid = response["uid"] as? String {
                    
                    URUserManager.getByKey(uid, completion: { (user, success) in
                        if let user = user {
                            completion(user, nil)
                        }
                    })
                    
                }else if let error = response["error"] as? NSDictionary {
                    let errorCode = error["code"] as! String
                    switch errorCode {
                        case "INVALID_EMAIL":
                            completion(nil, .invalidEmail)
                        break
                        case "INVALID_USER":
                            completion(nil, .invalidUser)
                        break
                        default:
                        break
                    }
                }
            }
        }
    }
    
    static func createUser(email:String,password:String, completion:@escaping (_ user:URUser?,_ authError:URFireBaseManagerAuthError?) -> Void) -> Void {
        Alamofire.request(String(format: URConstant.Auth.AUTH_REGISTER(), email,password)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let uid = response["uid"] as? String {
                    
                    URUserManager.getByKey(uid, completion: { (user, success) in
                        if let user = user {
                            completion(user, nil)
                        }
                    })
                    
                }else if let error = response["error"] as? NSDictionary {
                    let errorCode = error["code"] as! String
                    switch errorCode {
                    case "INVALID_EMAIL":
                        completion(nil, .invalidEmail)
                        break
                    case "INVALID_USER":
                        completion(nil, .invalidUser)
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    static func authUserWithFacebook(token:String, completion:@escaping (_ user:URUser?) -> Void) -> Void {
        print(String(format: URConstant.Auth.AUTH_FACEBOOK(), token))
        Alamofire.request(String(format: URConstant.Auth.AUTH_FACEBOOK(), token)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let uid = response["uid"] as? String {
                    URUserManager.getByKey(uid, completion: { (user, success) in
                        if let user = user {
                            completion(user)
                        }else {
                            let user = URUserLoginManager.getFacebookUserDataWithDictionary(response["facebook"] as! NSDictionary)
                            user.socialUid = uid
                            completion(user)
                        }
                    })
                    
                }
            }else{
                print(response)
            }
        }
    }
    
}
