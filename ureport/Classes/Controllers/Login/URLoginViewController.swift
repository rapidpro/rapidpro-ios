//
//  URLoginViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 07/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore

class URLoginViewController: UIViewController, URUserLoginManagerDelegate, ISTermsViewControllerDelegate {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btLogin: UIButton!
    @IBOutlet weak var btFacebookLogin: UIButton!
    @IBOutlet weak var btGooglePlusLogin: UIButton!
    @IBOutlet weak var btSignUp: UIButton!
    @IBOutlet weak var btTwitterLogin: UIButton!
    @IBOutlet weak var btSkipLogin: UIButton!
    @IBOutlet weak var lbOr: UILabel!
    
    var appDelegate:AppDelegate!
    var userLoginManager:URUserLoginManager!
    
    let termsViewController:ISTermsViewController = ISTermsViewController(fileName: "terms", fileExtension: "rtf", btAcceptColor: UIColor(rgba:"#49D080"), btCancelColor: UIColor(rgba:"#D0D0D0"), btAcceptTitle: "Accept", btCancelTitle: "Cancel", btAcceptTitleColor: UIColor.whiteColor(), btCancelTitleColor: UIColor.blackColor(), setupButtonAsRounded: true, setupBackgroundViewAsRounded: true)
    
    init() {
        super.init(nibName: "URLoginViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        userLoginManager = URUserLoginManager()
        
        setupUI()
        URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Main Login Options")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    //MARK: URTermsViewControllerDelegate
    
    func userDidAcceptTerms(accept: Bool) {
        
        self.termsViewController.close { (finish) in }
        
        if accept == true {
            let settings = URSettings.getSettings()
            settings.firstRun = false
            URSettings.saveSettingsLocaly(settings)
        }
    }
    
    //MARK: URUserLoginManagerDelegate
    
    func userHasLoggedInGoogle(user: URUser) {
        ProgressHUD.dismiss()
        if user.key.isEmpty {
        }else{
            
            URUserManager.getByKey(user.key, completion: { (userById,exists) -> Void in
                if exists {
                    
                    self.updateUserDataInRapidPro(userById!)
                    
                    URUserLoginManager.setUserAndCountryProgram(userById!)
                }else {
                    self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user, updateMode:false),animated:true)
                }
            })
        }
    }
    
    //MARK: Class Methods
    
    func updateUserDataInRapidPro(user:URUser) {
        
        URRapidProContactUtil.buildRapidProUserDictionaryWithContactFields(user, country: URCountry(code:"")) { (rapidProUserDictionary:NSDictionary) -> Void in
            URRapidProManager.saveUser(user, country: URCountry(code:user.country),setupGroups: false, completion: { (response) -> Void in
                URRapidProContactUtil.rapidProUser = NSMutableDictionary()
                URRapidProContactUtil.groupList = []
                print(response)
            })
        }
        
    }
    
    func setupUI() {
        
        self.lbOr.text = "login_or".localized
        self.btSkipLogin.setTitle("login_skip".localized, forState: UIControlState.Normal)
        self.btSignUp.setTitle("login_sign_up".localized, forState: UIControlState.Normal)
        self.btLogin.setTitle("login".localized, forState: UIControlState.Normal)
        self.btFacebookLogin.setTitle("login_facebook".localized, forState: UIControlState.Normal)
        self.btTwitterLogin.setTitle("login_twitter".localized, forState: UIControlState.Normal)
        self.btGooglePlusLogin.setTitle("login_google".localized, forState: UIControlState.Normal)
        
        self.btSignUp.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }
    
    //MARK: Button Events
    
    @IBAction func btSkipLoginTapped(sender: AnyObject) {
        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
    }
    
    @IBAction func btTwitterTapped(sender: AnyObject) {
        
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            ProgressHUD.show(nil)
            URUserLoginManager.loginWithTwitter { (user) -> Void in
                ProgressHUD.dismiss()
                if user == nil || user!.key.isEmpty {
                    
                    let alert = UIAlertController(title: nil, message: "twitter_error_message".localized, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                        UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=TWITTER")!)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                    ProgressHUD.show(nil)
                    URUserManager.getByKey(user!.key, completion: { (userById,exists) -> Void in
                        ProgressHUD.dismiss()
                        if exists {
                            
                            self.updateUserDataInRapidPro(userById!)
                            URUserLoginManager.setUserAndCountryProgram(userById!)
                            
                        }else {
                            self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user!, updateMode:false),animated:true)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func btLoginTapped(sender: AnyObject) {
        
        self.navigationController!.pushViewController(URLoginCredentialsViewController(), animated: true)
        
    }
    @IBAction func btFacebookTapped(sender: AnyObject) {
        
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            ProgressHUD.show(nil)
            URUserLoginManager.loginWithFacebook(self) { (user) -> Void in
                ProgressHUD.dismiss()
                if user == nil || user!.key.isEmpty {
                    
                }else{
                    ProgressHUD.show(nil)
                    URUserManager.getByKey(user!.key, completion: { (userById,exists) -> Void in
                        ProgressHUD.dismiss()
                        if exists {
                            
                            self.updateUserDataInRapidPro(userById!)
                            
                            URUserLoginManager.setUserAndCountryProgram(userById!)
                            
                        }else {
                            self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user!,updateMode:false),animated:true)
                        }
                    })
                }
                
            }
        }
    }
    @IBAction func btGooglePlusTapped(sender: AnyObject) {
        
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            ProgressHUD.show(nil)
            userLoginManager.loginViewController = self
            userLoginManager.loginWithGoogle(self)
            userLoginManager.delegate = self
        }
        
    }
    
    @IBAction func btSignUpTapped(sender: AnyObject) {
        self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.SIGNUP_PRIMARY), animated: true)
    }
    
}