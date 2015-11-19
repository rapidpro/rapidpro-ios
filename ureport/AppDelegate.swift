//
//  AppDelegate.swift
//  ureport
//
//  Created by Daniel Amaral on 07/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    var loginViewController: URLoginViewController?
    var navigation:UINavigationController?
    var revealController:SWRevealViewController?
    
    var gcmSenderID: String!
    var registrationOptions = [String: AnyObject]()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        loginViewController = URLoginViewController(nibName: "URLoginViewController", bundle: nil)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent,animated:true)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = URConstant.Color.YELLOW
        
        URCountryProgramManager.deactivateSwitchCountryProgram()
        Firebase.defaultConfig().persistenceEnabled = false
        setupGoogle()
//        setupGCM()
//        requestPermissionForPushNotification(application)
        setupAWS()
        createDirectoryToImageUploads()
        checkMainViewControllerToShow()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func createDirectoryToImageUploads() {
        do {
                        
            try NSFileManager.defaultManager().createDirectoryAtPath(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").path!, withIntermediateDirectories:true, attributes: nil)
        } catch let error1 as NSError {
                print("Creating 'upload' directory failed. Error: \(error1)")
        }
    }
    
    func setupAWS() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: URConstant.AWS.COGNITO_IDENTITY_POLL_ID())
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
    }
    
    func setupGCM() {
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID        
        
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        
    }
    
    func requestPermissionForPushNotification(application:UIApplication) {
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let types:UIUserNotificationType = ([.Alert, .Badge, .Sound])
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
    }
    
    func setupGoogle() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
    }

    func checkMainViewControllerToShow(){
        if URUser.activeUser() != nil {
            URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
        }else {
            URNavigationManager.setupNavigationControllerWithLoginViewController()
        }
    }
    
    //MARK: GCMReceiverDelegate
    
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            
        } else {

        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {

    }
    
    func didDeleteMessagesOnServer() {

    }
    
    //MARK: GGLInstanceIDDelegate
    
    func onTokenRefresh() {
        print("The GCM registration token needs to be changed.")
    }
    
    //MARK: Application Methods
    
    func applicationDidBecomeActive(application: UIApplication) {
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
//                self.subscribeToTopic()

            }
        })
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        GCMService.sharedInstance().disconnect()
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
//            NSNotificationCenter.defaultCenter().postNotificationName(URGCMManager.registrationKey, object: nil, userInfo: userInfo)
    }

    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            print("Notification received: \(userInfo)")
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
//            NSNotificationCenter.defaultCenter().postNotificationName(URGCMManager.messageKey, object: nil, userInfo: userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken, kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: URGCMManager.registrationHandler)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme.hasPrefix("fb") {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else {
            return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }

}

