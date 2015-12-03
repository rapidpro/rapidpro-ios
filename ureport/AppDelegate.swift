//
//  AppDelegate.swift
//  ureport
//
//  Created by Daniel Amaral on 07/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase
import ObjectMapper

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
        
        NSUserDefaults.saveIncomingAvatarSetting(true)
        NSUserDefaults.saveOutgoingAvatarSetting(true)
        
        URCountryProgramManager.deactivateSwitchCountryProgram()
        Firebase.defaultConfig().persistenceEnabled = false
        setupGoogle()
        requestPermissionForPushNotification(application)
        setupGCM(application)
        setupAWS()
        createDirectoryToImageUploads()
        checkMainViewControllerToShow(launchOptions)
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
    
    func setupGCM(application: UIApplication) {
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID        
        
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
    }
    
    func requestPermissionForPushNotification(application:UIApplication) {
        let types:UIUserNotificationType = ([.Alert, .Badge, .Sound])
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }        
    
    func setupGoogle() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }

    func checkMainViewControllerToShow(launchOptions: [NSObject: AnyObject]?) {
        
        if NSUserDefaults.standardUserDefaults().objectForKey("FirstRun") == nil {
            NSUserDefaults.standardUserDefaults().setObject("firstrun", forKey: "FirstRun")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            URNavigationManager.setupNavigationControllerWithTutorialViewController()
        }else {
            if URUser.activeUser() != nil {
                var mainController: URMainViewController
                
                if let chatRoomKey = getChatRoomKey(launchOptions) {
                    mainController = URMainViewController(chatRoomKey: chatRoomKey)
                } else {
                    mainController = URMainViewController()
                }
                URNavigationManager.setupNavigationControllerWithMainViewController(mainController)
            }else {
                URNavigationManager.setupNavigationControllerWithLoginViewController()
            }
        }
    }
    
    func getChatRoomKey(launchOptions: [NSObject: AnyObject]?) -> String? {
        if launchOptions != nil {
            let notificationData = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if notificationData != nil && notificationData!["chatRoom"] != nil {
                let chatRoom = convertStringToDictionary(notificationData!["chatRoom"] as! String)
                return chatRoom!["key"] as? String
            }
        }
        return nil
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
                print("Connected with GCM")
            }
        })
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        GCMService.sharedInstance().disconnect()
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        completionHandler(.NewData)
    }
    
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
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

