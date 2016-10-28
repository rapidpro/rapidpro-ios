//
//  URSocialNetworkManager.swift
//  ureport
//
//  Created by Daniel Amaral on 20/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

protocol URUserLoginManagerDelegate {
    func userHasLoggedInGoogle(_ user:URUser)
}

class URUserLoginManager: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {

    //MARK: Login Methods
    
    var loginViewController:UIViewController?
    var delegate:URUserLoginManagerDelegate?
    var googleSignIn: GIDSignIn!
    
    override init() {
        super.init()
        self.googleSignIn = GIDSignIn.sharedInstance()
        self.googleSignIn.delegate = self
        self.googleSignIn.uiDelegate = self
    }
    
    class func logoutFromSocialNetwork() {
        GIDSignIn.sharedInstance().disconnect()
        FBSDKLoginManager().logOut()
        URFireBaseManager.sharedLoginInstance().unauth()
    }
    
    class func loginWithFacebook(_ viewController:UIViewController, completion:@escaping (URUser?) -> Void ) {
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        
        login.logIn(withReadPermissions: ["email","user_birthday"], from: viewController) { (FBSDKLoginManagerLoginResult, error) -> Void in
            if error != nil {
                print(error)
                completion(nil)
            }
            else {
                if (FBSDKLoginManagerLoginResult?.isCancelled)! {
                    completion(nil)
                } else {
                    if FBSDKAccessToken.current() != nil {
                        URFireBaseManager.sharedLoginInstance().auth(withOAuthProvider: URType.Facebook, token: FBSDKAccessToken.current().tokenString, withCompletionBlock: { (error, authData) -> Void in
                            if error != nil {
                                print(error)
                            }else{
                                let user: URUser = URUserLoginManager.getFacebookUserData(authData!)
                                completion(user)
                            }
                        })
                    }
                }
            }
            
        }
        
    }
    
    class func loginWithTwitter(_ completion:@escaping (URUser?) ->Void ) {
        let twitterAuthHelper:TwitterAuthHelper = TwitterAuthHelper(firebaseRef: URFireBaseManager.sharedLoginInstance(), apiKey: URConstant.SocialNetwork.TWITTER_APP_ID())
        
        twitterAuthHelper.selectTwitterAccount { (error, accounts:[Any]?) -> Void in
            
            if error != nil {
                completion(nil)
            }else {
                twitterAuthHelper.authenticateAccount(accounts?[0] as! ACAccount, withCallback: { (error, authData) -> Void in
                    if let authData = authData {
                        let user: URUser = URUserLoginManager.getTwitterUserData(authData)
                        completion(user)
                    }else {
                        completion(nil)
                    }
                    
                })
            }
            
        }
        
    }
    
    //MARK: GoogleSigninDelegate
    
    func loginWithGoogle(_ viewController:UIViewController) {
        googleSignIn.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.loginViewController!.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error)
        }else{
            URFireBaseManager.sharedLoginInstance().auth(withOAuthProvider: URType.Google, token: user.authentication.accessToken, withCompletionBlock: { (error, authData) -> Void in
                if error != nil {
                    print(error)
                }else{
                    let user: URUser = URUserLoginManager.getGoogleUserData(authData!)
                    if self.delegate != nil {
                        self.delegate?.userHasLoggedInGoogle(user)
                    }
                }
            })
        }
    }
    
    
    //MARK: auth Methods
    
    class func login(_ email:String,password:String,completion:@escaping (FAuthenticationError?,Bool) -> Void) {
        URFireBaseManager.sharedLoginInstance().authUser(email, password: password,
                                                    withCompletionBlock: { error, authData in
                                                        if error != nil {
                                                            
                                                            if let errorCode = FAuthenticationError(rawValue: (error?._code)!) {
                                                                switch (errorCode) {
                                                                case .userDoesNotExist:
                                                                    completion(FAuthenticationError.userDoesNotExist,false)
                                                                case .invalidEmail:
                                                                    completion(FAuthenticationError.invalidEmail,false)
                                                                case .invalidPassword:
                                                                    completion(FAuthenticationError.invalidPassword,false)
                                                                default:
                                                                    completion(FAuthenticationError.unknown,false)
                                                                }
                                                                print(error)
                                                            }
                                                        } else {
                                                            
                                                            URUserManager.getByKey((authData?.uid)!, completion: { (user,exists) -> Void in
                                                                if (user != nil && exists) {
                                                                    URLoginViewController.updateUserDataInRapidPro(user!)
                                                                    
                                                                    URUserLoginManager.setUserAndCountryProgram(user!)
                                                                    completion(nil,true)
                                                                }else{
                                                                    completion(nil,false)
                                                                }
                                                            })
                                                        }
        })
    }
    
    class func resetPassword(_ email:String,completion:@escaping (Bool) -> Void) {
        URFireBaseManager.sharedLoginInstance().resetPassword(forUser: email, withCompletionBlock: { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    class func setLoggedUser(_ user:URUser) {
        URUserManager.checkIfUserIsMasterModerator(user.key) { (isMasterModerator) -> Void in
            if isMasterModerator == true {
                user.masterModerator = true
                
                URUser.setActiveUser(user)
            }else {
                
                URUserManager.checkIfUserIsCountryProgramModerator(user.key, completion: { (isModerator) -> Void in
                    if isModerator == true {
                        user.moderator = isModerator as NSNumber!
                    }
                    
                    URUser.setActiveUser(user)
                })
                
            }
        }
    }
    
    class func setLoggedUserWithCompletion(_ user:URUser,mainCompletion:@escaping (_ finish:Bool) -> Void) {
        URUserManager.checkIfUserIsMasterModerator(user.key) { (isMasterModerator) -> Void in
            if isMasterModerator == true {
                user.masterModerator = true
                
                URUser.setActiveUser(user)
                mainCompletion(true)
            }else {
                
                URUserManager.checkIfUserIsCountryProgramModerator(user.key, completion: { (isModerator) -> Void in
                    if isModerator == true {
                        user.moderator = isModerator as NSNumber!
                    }
                    
                    URUser.setActiveUser(user)
                    mainCompletion(true)
                })
                
            }
        }
    }
    
    class func setUserAndCountryProgram(_ user:URUser) {
        //        user.chatRooms = nil
        URUser.setActiveUser(user)
        URUserLoginManager.setLoggedUser(user)
        
        URCountryProgramManager.setActiveCountryProgram(URCountryProgramManager.getCountryProgramByCountry(URCountry(code: user.country)))
        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
    }
    
    //MARK: GetUserData Methods
    class func getFacebookUserData(_ authData:FAuthData) -> URUser{
        let user = URUser()
        
        user.key = authData.uid
        user.nickname = (authData.providerData["displayName"] as? String)?.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        user.email = authData.providerData["email"] as? String
        user.picture = authData.providerData["profileImageURL"] as? String
        user.gender = ((authData.providerData["cachedUserProfile"]! as AnyObject).object(forKey: "gender") as! String) == "male" ? URGender.Male : URGender.Female
        user.type = URType.Facebook
        
        return user
    }
    
    class func getTwitterUserData(_ authData:FAuthData) -> URUser{
        let user = URUser()
        
        user.key = authData.uid
        user.nickname = authData.providerData["username"] as? String
        user.email = authData.providerData["email"] as? String
        user.picture = authData.providerData["profileImageURL"] as? String
        user.type = URType.Twitter
        
        return user
    }
    
    class func getGoogleUserData(_ authData:FAuthData) -> URUser{
        let user = URUser()
        
        user.key = authData.uid
        user.nickname = (authData.providerData["displayName"] as? String)?.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        user.email = authData.providerData["email"] as? String
        user.picture = authData.providerData["profileImageURL"] as? String
        user.type = URType.Google
        
        return user
    }
    
}
