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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        loginViewController = URLoginViewController()
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent,animated:true)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = URConstant.Color.YELLOW
        
        UserDefaults.saveIncomingAvatarSetting(true)
        UserDefaults.saveOutgoingAvatarSetting(true)
        
        URIPCheckManager.getCountryCodeByIP { (countryCode) in
            if let countryCode = countryCode {
                print(countryCode)
            }
        }
        
        URCountryProgramManager.deactivateSwitchCountryProgram()
        Firebase.defaultConfig().persistenceEnabled = false
        setupGoogle()
        requestPermissionForPushNotification(application)
        setupGCM(application)
        setupAWS()
        createDirectoryToImageUploads()
        
        URReviewModeManager.checkIfIsInReviewMode { (reviewMode) -> Void in
            
            let settings = URSettings.getSettings()
            settings.reviewMode = reviewMode as NSNumber
            
            URSettings.saveSettingsLocaly(settings)
        }
        
        checkMainViewControllerToShow(launchOptions)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func createDirectoryToImageUploads() {
        do {
                        
            try FileManager.default.createDirectory(atPath: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload").path, withIntermediateDirectories:true, attributes: nil)
        } catch let error1 as NSError {
                print("Creating 'upload' directory failed. Error: \(error1)")
        }
    }
    
    func setupAWS() {
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: URConstant.AWS.COGNITO_IDENTITY_POLL_ID())
        
//        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: URConstant.AWS.ACCESS_KEY(), secretKey: URConstant.AWS.ACCESS_SECRET())
        
        let configuration = AWSServiceConfiguration(region: URFireBaseManager.region, credentialsProvider: URFireBaseManager.credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
    }
    
    func setupGCM(_ application: UIApplication) {
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID        
        
        let instanceIDConfig = GGLInstanceIDConfig.default()
        instanceIDConfig?.delegate = self
        GGLInstanceID.sharedInstance().start(with: instanceIDConfig)
        
        let gcmConfig = GCMConfig.default()
        gcmConfig?.receiverDelegate = self
        GCMService.sharedInstance().start(with: gcmConfig)
    }
    
    func requestPermissionForPushNotification(_ application:UIApplication) {
        let types:UIUserNotificationType = ([.alert, .badge, .sound])
        let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }        
    
    func setupGoogle() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        let gai: GAI = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
    }
    
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }

    func checkMainViewControllerToShow(_ launchOptions: [AnyHashable: Any]?) {
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("firstrun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            URNavigationManager.setupNavigationControllerWithTutorialViewController()
        }else {
            if URUser.activeUser() != nil {
                if let launchOptions = launchOptions {
                    if let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary{
                        openNotification(userInfo)
                    }
                }else {
                    URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
                }
            }else {
                URNavigationManager.setupNavigationControllerWithLoginViewController()
            }
        }
    }
    
    func getChatRoomKey(_ userInfo:NSDictionary) -> String? {
        if userInfo["chatRoom"] != nil {
            let chatRoom = convertStringToDictionary(userInfo["chatRoom"] as! String)
            return chatRoom!["key"] as? String
        }
        return nil
    }
    
    //MARK: GCMReceiverDelegate
    
    func didSendDataMessage(withID messageID: String!) {

    }
    
    func didDeleteMessagesOnServer() {

    }
    
    //MARK: GGLInstanceIDDelegate
    
    func onTokenRefresh() {
        print("The GCM registration token needs to be changed.")
    }
    
    //MARK: Notification Methods
    
    func openNotification(_ userInfo:NSDictionary) {
        
        var notificationType:String? = nil
        
        if let type = userInfo["type"] as? String {
            notificationType = type
        }else if let type = userInfo["gcm.notification.type"] as? String {
            notificationType = type
        }
        
        if let notificationType = notificationType {
            switch notificationType {
            case URConstant.NotificationType.CHAT:
                
                if let chatRoomKey = getChatRoomKey(userInfo) {
                    if UIApplication.shared.applicationState != UIApplicationState.active {
                        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController(chatRoomKey: chatRoomKey))
                    }else{
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "newChatReceived"), object: userInfo)
                        
                        if let visibleViewController = URNavigationManager.navigation.visibleViewController {
                            if !(visibleViewController is URMessagesViewController) {
                                //                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            }
                        }
                    }
                }
                
                break
            case URConstant.NotificationType.RAPIDPRO:
                
                if URRapidProManager.sendingAnswers {
                    break
                }
                
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController(viewControllerToShow: URClosedPollTableViewController()))
                break
            default:
                break
            }
        }
        
    }
    
    //MARK: Application Methods
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        GCMService.sharedInstance().connect(handler: {
            (error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error?.localizedDescription)")
            } else {
                print("Connected with GCM")
            }
        })
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        GCMService.sharedInstance().disconnect()
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let _ = URUser.activeUser() {
            openNotification(userInfo as NSDictionary)
        }
        
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject, kGGLInstanceIDAPNSServerTypeSandboxOption:URFireBaseManager.GCM_DEBUG_MODE as AnyObject]
//        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: URGCMManager.registrationHandler)
        
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions) { (registrationToken, error) in
            if (registrationToken != nil) {
                if let user = URUser.activeUser() {
                    if (user.pushIdentity == nil || user.pushIdentity!.isEmpty) || (!user.pushIdentity!.isEmpty && (user.pushIdentity! != registrationToken)){
                        user.pushIdentity = registrationToken
                        URUserManager.updatePushIdentity(user)
                    }
                }
            } else {
                print("Registration to GCM failed with error: \(error?.localizedDescription)")
            }
        }
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (url.scheme?.hasPrefix("fb"))! {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        else {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }

}

