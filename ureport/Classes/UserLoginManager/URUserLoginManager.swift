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
    func userHasLoggedInGoogle(user:URUser)
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
        URFireBaseManager.sharedInstance().unauth()
    }
    
    class func loginWithFacebook(viewController:UIViewController, completion:(URUser?) -> Void ) {
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        
        login.logInWithReadPermissions(["email","user_birthday"], fromViewController: viewController) { (FBSDKLoginManagerLoginResult, error) -> Void in
            if error != nil {
                print(error)
                completion(nil)
            }
            else {
                if FBSDKLoginManagerLoginResult.isCancelled {
                    completion(nil)
                } else {
                    if FBSDKAccessToken.currentAccessToken() != nil {
                        URFireBaseManager.sharedInstance().authWithOAuthProvider(URType.Facebook, token: FBSDKAccessToken.currentAccessToken().tokenString, withCompletionBlock: { (error, authData) -> Void in
                            if error != nil {
                                print(error)
                            }else{
                                let user: URUser = URUserLoginManager.getFacebookUserData(authData)
                                completion(user)
                            }
                        })
                    }
                }
            }
            
        }
        
    }
    
    class func loginWithTwitter(completion:(URUser?) ->Void ) {
        let twitterAuthHelper:TwitterAuthHelper = TwitterAuthHelper(firebaseRef: URFireBaseManager.sharedInstance(), apiKey: URConstant.SocialNetwork.TWITTER_APP_ID())
        
        twitterAuthHelper.selectTwitterAccountWithCallback { (error, accounts:[AnyObject]!) -> Void in
            
            if error != nil {
                completion(nil)
            }else {
                twitterAuthHelper.authenticateAccount(accounts[0] as! ACAccount, withCallback: { (error, authData) -> Void in
                    let user: URUser = URUserLoginManager.getTwitterUserData(authData)
                    completion(user)
                })
            }
            
        }
        
    }
    
    //MARK: GoogleSigninDelegate
    
    func loginWithGoogle(viewController:UIViewController) {
        googleSignIn.signIn()
    }
    
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        self.loginViewController!.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if error != nil {
            print(error)
        }else{
            URFireBaseManager.sharedInstance().authWithOAuthProvider(URType.Google, token: user.authentication.accessToken, withCompletionBlock: { (error, authData) -> Void in
                if error != nil {
                    print(error)
                }else{
                    let user: URUser = URUserLoginManager.getGoogleUserData(authData)
                    if self.delegate != nil {
                        self.delegate?.userHasLoggedInGoogle(user)
                    }
                }
            })
        }
    }
    
    //MARK: auth Methods
    
    class func login(email:String,password:String,completion:(FAuthenticationError?,Bool) -> Void) {
        URFireBaseManager.sharedInstance().authUser(email, password: password,
                                                    withCompletionBlock: { error, authData in
                                                        if error != nil {
                                                            
                                                            if let errorCode = FAuthenticationError(rawValue: error.code) {
                                                                switch (errorCode) {
                                                                case .UserDoesNotExist:
                                                                    completion(FAuthenticationError.UserDoesNotExist,false)
                                                                case .InvalidEmail:
                                                                    completion(FAuthenticationError.InvalidEmail,false)
                                                                case .InvalidPassword:
                                                                    completion(FAuthenticationError.InvalidPassword,false)
                                                                default:
                                                                    completion(FAuthenticationError.Unknown,false)
                                                                }
                                                                print(error)
                                                            }
                                                        } else {
                                                            
                                                            URUserManager.getByKey(authData.uid, completion: { (user,exists) -> Void in
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
    
    class func resetPassword(email:String,completion:(Bool) -> Void) {
        URFireBaseManager.sharedInstance().resetPasswordForUser(email, withCompletionBlock: { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    class func setLoggedUser(user:URUser) {
        URUserManager.checkIfUserIsMasterModerator(user.key) { (isMasterModerator) -> Void in
            if isMasterModerator == true {
                user.masterModerator = true
                
                URUser.setActiveUser(user)
            }else {
                
                URUserManager.checkIfUserIsCountryProgramModerator(user.key, completion: { (isModerator) -> Void in
                    if isModerator == true {
                        user.moderator = isModerator
                    }
                    
                    URUser.setActiveUser(user)
                })
                
            }
        }
    }
    
    class func setLoggedUserWithCompletion(user:URUser,mainCompletion:(finish:Bool) -> Void) {
        URUserManager.checkIfUserIsMasterModerator(user.key) { (isMasterModerator) -> Void in
            if isMasterModerator == true {
                user.masterModerator = true
                
                URUser.setActiveUser(user)
                mainCompletion(finish: true)
            }else {
                
                URUserManager.checkIfUserIsCountryProgramModerator(user.key, completion: { (isModerator) -> Void in
                    if isModerator == true {
                        user.moderator = isModerator
                    }
                    
                    URUser.setActiveUser(user)
                    mainCompletion(finish: true)
                })
                
            }
        }
    }
    
    class func setUserAndCountryProgram(user:URUser) {
        //        user.chatRooms = nil
        URUser.setActiveUser(user)
        URUserLoginManager.setLoggedUser(user)
        
        URCountryProgramManager.setActiveCountryProgram(URCountryProgramManager.getCountryProgramByCountry(URCountry(code: user.country)))
        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
    }
    
    //MARK: GetUserData Methods
    class func getFacebookUserData(authData:FAuthData) -> URUser{
        let user = URUser()
        
        user.key = authData.uid
        user.nickname = (authData.providerData["displayName"] as? String)?.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        user.email = authData.providerData["email"] as? String
        user.picture = authData.providerData["profileImageURL"] as? String
        user.gender = (authData.providerData["cachedUserProfile"]!.objectForKey("gender") as! String) == "male" ? URGender.Male : URGender.Female
        user.type = URType.Facebook
        
        return user
    }
    
    class func getTwitterUserData(authData:FAuthData) -> URUser{
        let user = URUser()
        
        user.key = authData.uid
        user.nickname = authData.providerData["username"] as? String
        user.email = authData.providerData["email"] as? String
        user.picture = authData.providerData["profileImageURL"] as? String
        user.type = URType.Twitter
        
        return user
    }
    
    class func getGoogleUserData(authData:FAuthData) -> URUser{
        let user = URUser()
        
        user.key = authData.uid
        user.nickname = (authData.providerData["displayName"] as? String)?.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        user.email = authData.providerData["email"] as? String
        user.picture = authData.providerData["profileImageURL"] as? String
        user.type = URType.Google
        
        return user
    }
    
}