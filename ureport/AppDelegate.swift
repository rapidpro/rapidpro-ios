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
import UserNotifications
import TwitterKit
import TwitterCore

enum UREnvironment {
    case sandbox
    case production
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let environment: UREnvironment = .production
    
    var window: UIWindow?
    var loginViewController: URLoginViewController?
    var navigation:UINavigationController?
    var revealController:SWRevealViewController?
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

        switch AppDelegate.environment {
        case .sandbox:
            if let databaseOptions = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "FirebaseDatabaseDev-Info", ofType: "plist")!) {
                FirebaseApp.configure(name: "database", options: databaseOptions)
            }
        case .production:
            if let databaseOptions = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "FirebaseDatabaseProd-Info", ofType: "plist")!) {
                dump(databaseOptions)
                FirebaseApp.configure(name: "database", options: databaseOptions)
            }
        }
        
        if let fcmOptions = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "FirebaseNotificationsProd-Info", ofType: "plist")!) {
            FirebaseApp.configure(options: fcmOptions)
        }
        
//        Database.database(app: URFireBaseManager.databaseApp).isPersistenceEnabled = true
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        Twitter.sharedInstance().start(withConsumerKey: URConstant.SocialNetwork.TWITTER_APP_ID(), consumerSecret: URConstant.SocialNetwork.TWITTER_CONSUMER_SECRET())
        requestPermissionForPushNotification(application)
        FCMChannelManager.setup()
        setupAWS()
        createDirectoryToImageUploads()
        Messaging.messaging().delegate = self
        
        
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

    func requestPermissionForPushNotification(_ application:UIApplication) {
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            // set the type as sound or badge
            center.requestAuthorization(options: [.sound,.alert,.badge], completionHandler: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("success: \(success)")
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            })
        } else {
            let types:UIUserNotificationType = ([.alert, .badge, .sound])
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }


    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        guard let data = text.data(using: String.Encoding.utf8) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            return json
        } catch {
            print("Something went wrong")
            return nil
        }
    }

    func checkMainViewControllerToShow(_ launchOptions: [AnyHashable: Any]?) {

        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("firstrun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            
            URNavigationManager.setupNavigationControllerWithTutorialViewController()
        } else {
            if URUser.activeUser() != nil {
                if let launchOptions = launchOptions {
                    if let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]{
                        openNotification(userInfo)
                    }
                } else {
                    URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
                }
            } else {
                URNavigationManager.setupNavigationControllerWithLoginViewController()
            }
        }
    }
    
    func getChatRoomKey(_ userInfo:[AnyHashable:Any]) -> String? {
        if userInfo["chatRoom"] != nil {
            let chatRoom = convertStringToDictionary(userInfo["chatRoom"] as! String)
            return chatRoom!["key"] as? String
        }
        return nil
    }

    //MARK: Notification Methods
    
    func openNotification(_ userInfo:[AnyHashable:Any]) {
        
        var notificationType:String? = nil
        
        if let type = userInfo["type"] as? String {
            notificationType = type
        }else if let type = userInfo["gcm.notification.type"] as? String {
            notificationType = type
        }
        
        if let notificationType = notificationType?.lowercased() {
            switch notificationType {
            case URConstant.NotificationType.RAPIDPRO://CHAT:
                if UIApplication.shared.applicationState != UIApplicationState.active, let chatRoomKey = getChatRoomKey(userInfo) {
                    URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController(chatRoomKey: chatRoomKey))
                }else{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "newMessageReceived"), object: userInfo)
                    if let visibleViewController = URNavigationManager.navigation.visibleViewController {
                        if !(visibleViewController is URMessagesViewController) {
                            (URNavigationManager.navigation.viewControllers.first as? URMainViewController)?.addBadgeMyChatsViewController()
                            //                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                }
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

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Did receive remote notification")
    }
    
    //MARK: Application Methods
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Enter on touch notification
        let userInfo = response.notification.request.content.userInfo
        
        if let _ = URUser.activeUser() {
            openNotification(userInfo)
        }
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let _ = URUser.activeUser() {
            openNotification(userInfo)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        URIPCheckManager.getCountryCodeByIP { (countryCode) in}
    }

    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let _ = URUser.activeUser() {
            openNotification(userInfo)
        }
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var debugMode: Bool!
            
        switch AppDelegate.environment {
        case .sandbox:
            debugMode = true
        case .production:
            debugMode = false
        }

        Messaging.messaging().apnsToken = deviceToken

        if let fcmToken = URSettingsManager.getFCMToken(), let user = URUser.activeUser() {
            user.pushIdentity = fcmToken
            URUser.setActiveUser(user)
            URUserManager.updatePushIdentity(user, completion: { success in
                guard success else { return }
                URGCMManager.onFCMRegistered(user: user)
            })
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if (url.scheme?.hasPrefix("fb"))! {
            let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: nil)
        } else if (url.scheme?.hasPrefix("twitterkit"))! {
            return Twitter.sharedInstance().application(app, open: url, options: options)
        } else {
            let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: nil)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        if let user = URUser.activeUser() {
            user.pushIdentity = fcmToken
            URUser.setActiveUser(user)
        }
        
        print("Firebase registration token was refreshed: \(fcmToken)")
        URSettingsManager.saveFCMToken(fcmToken: fcmToken)
        FCMChannelManager.saveFCMToken(fcmToken: fcmToken)
    }
}

