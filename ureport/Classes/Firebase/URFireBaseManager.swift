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

enum URFireBaseManagerAuthError: Error {
    case invalidEmail
    case invalidUser
    case invalidPassword
    case emailTaken
}

class URFireBaseManager {
    static var region: AWSRegionType {
        get {
            var reg: AWSRegionType!
            switch AppDelegate.environment {
            case .sandbox:
                reg = .USEast1
            case .production:
                reg = .USEast1
            }
            return reg
        }
    }
    
    static var Properties: String {
        get {
            var filename: String!
            switch AppDelegate.environment {
            case .sandbox:
                filename = "Key-debug"
            case .production:
                filename = "Key"
            }
            return filename
        }
    }
    
    static var credentialsProvider: AWSCredentialsProvider {
        get {
            var provider: AWSCredentialsProvider!
            switch AppDelegate.environment {
            case .sandbox:
                provider = AWSCognitoCredentialsProvider(regionType: region, identityPoolId: URConstant.AWS.COGNITO_IDENTITY_POLL_ID())
            case .production:
                provider = AWSStaticCredentialsProvider(accessKey: URConstant.AWS.ACCESS_KEY(), secretKey: URConstant.AWS.ACCESS_SECRET())
            }
            return provider
        }
    }
    

    static var databaseApp: FirebaseApp {
        return FirebaseApp.app(name: "database")!
    }

    static let Reference: DatabaseReference = Database.database(app: FirebaseApp.app(name: "database")!).reference()

    static func sharedInstance() -> DatabaseReference {
        
        if let countryCode = URIPCheckManager.countryCode , URIPCheckManager.proxyCountryCodes.contains(countryCode) {
            return Database.database().reference(fromURL: "http://ureport-socket.ilhasoft.mobi:5000")
        }else {
            return Reference
        }
    }

    static func authUserWithPassword(email:String,password:String, completion:@escaping (_ user:URUser?,_ authError: Error?) -> Void) -> Void {
        Alamofire.request(String(format: URConstant.Auth.AUTH_LOGIN(), email,password)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let uid = response["uid"] as? String {
                    URUserManager.getByKey(uid, completion: { (user, success) in
                        if let user = user {
                            completion(user, nil)
                        }
                    })
                    
                } else if let error = response["error"] as? NSDictionary {
                    let errorCode = error["code"] as! String
                    switch errorCode {
                        case "INVALID_EMAIL":
                            completion(nil, URFireBaseManagerAuthError.invalidEmail)
                        break
                        case "INVALID_USER":
                            completion(nil, URFireBaseManagerAuthError.invalidUser)
                        break
                        case "INVALID_PASSWORD":
                            completion(nil, URFireBaseManagerAuthError.invalidPassword)
                        break
                        default:
                        break
                    }
                }
            }
        }
    }

    static func createUser(email:String,password:String, completion:@escaping (_ user:URUser?, _ authError: Error?) -> Void) -> Void {
        Alamofire.request(String(format: URConstant.Auth.AUTH_REGISTER(), email,password)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let uid = response["uid"] as? String {
                    let user = URUser()
                    user.key = uid
                    completion(user, nil)
                } else if let error = response["error"] as? NSDictionary {
                    let errorCode = error["code"] as! String
                    switch errorCode {
                    case "EMAIL_TAKEN":
                        completion(nil, URFireBaseManagerAuthError.emailTaken)
                        break
                    // TODO: add wrong password error
                    default:
                        break
                    }
                } else {
                    completion(nil, nil)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    static func authUserWithFacebook(token:String, completion:@escaping (_ user:URUser?, _ pendingFirebaseRegistration: Bool?) -> Void) -> Void {
        Alamofire.request(String(format: URConstant.Auth.AUTH_FACEBOOK(), token)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary, let uid = response["uid"] as? String {
                URUserManager.getByKey(uid, completion: { (user, success) in
                    if let user = user {
                        user.socialUid = uid
                        completion(user, false)
                    } else {
                        let user = URUserLoginManager.getFacebookUserDataWithDictionary(response["facebook"] as! NSDictionary)
                        user.socialUid = uid
                        if user.key == nil {
                            user.key = uid
                        }
                        completion(user, true)
                    }
                })
                
            } else{
                completion(nil, nil)
                print(response)
            }
        }
    }
    
    static func authUserWithGoogle(token:String, completion:@escaping (_ user: URUser?) -> Void) -> Void {
        Alamofire.request(String(format: URConstant.Auth.AUTH_GOOGLE(), token)).responseJSON { (response:DataResponse<Any>) in
            if let response = response.result.value as? NSDictionary {
                if let uid = response["uid"] as? String {
                    URUserManager.getByKey(uid, completion: { (user, success) in
                        if let user = user {
                            user.socialUid = uid
                            completion(user)
                        }else {
                            let user = URUserLoginManager.getGoogleUserDataWithDictionary(response["google"] as! NSDictionary)
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
    
    static func authUserWithTwitter(userId: String, authToken: String, authTokenSecret: String, completion: @escaping (_ user:URUser?) -> Void) -> Void {
        print(String(format: URConstant.Auth.AUTH_TWITTER(), authToken, authTokenSecret, userId))
        
        Alamofire.request(String(format: URConstant.Auth.AUTH_TWITTER(), authToken, authTokenSecret, userId)).responseJSON { (response:DataResponse<Any>) in
            
            switch response.result {
                
            case .failure(let error):
                print(error.localizedDescription)
                
            case .success(let value):
                if let value = value as? [String: Any] {
                    if let uid = value["uid"] as? String {
                        URUserManager.getByKey(uid, completion: { (user, success) in
                            if let user = user, user.key != nil {
                                user.key = uid
                                completion(user)
                            } else {
                                let user = URUserLoginManager.getTwitterUserDataWithDictionary(value["twitter"] as! NSDictionary)
                                user.socialUid = uid
                                completion(user)
                            }
                        })
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    static func resetPassword(forUser email: String, withCompletionBlock completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth(app: URFireBaseManager.databaseApp).sendPasswordReset(withEmail: email, completion: { error in
            completion(error)
        })
    }
    
}
