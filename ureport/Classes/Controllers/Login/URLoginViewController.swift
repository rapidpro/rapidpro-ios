//
//  URLoginViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 07/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore
import MBProgressHUD

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
    
    let termsViewController:ISTermsViewController = ISTermsViewController(fileName: "terms", fileExtension: "rtf", btAcceptColor: UIColor(rgba:"#49D080"), btCancelColor: UIColor(rgba:"#D0D0D0"), btAcceptTitle: "Accept", btCancelTitle: "Cancel", btAcceptTitleColor: UIColor.white, btCancelTitleColor: UIColor.black, setupButtonAsRounded: true, setupBackgroundViewAsRounded: true)
    
    init() {
        super.init(nibName: "URLoginViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        userLoginManager = URUserLoginManager()
        
        setupUI()
        URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Main Login Options")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
        checkIfIsSyriaUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MBProgressHUD.hide(for: self.view, animated: true)
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
    }
    
    //MARK: URTermsViewControllerDelegate
    
    func userDidAcceptTerms(_ accept: Bool) {
        
        self.termsViewController.closeWithCompletion { (closed) in            
        }
        
        if accept == true {
            let settings = URSettings.getSettings()
            settings.firstRun = false
            URSettings.saveSettingsLocaly(settings)
        }
    }
    
    //MARK: URUserLoginManagerDelegate
    
    func userHasLoggedInGoogle(_ user: URUser) {
        MBProgressHUD.hide(for: self.view, animated: true)
        if user.key == nil {
            self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user, updateMode:false),animated:true)
        }else{
            URLoginViewController.updateUserDataInRapidPro(user)
            URUserLoginManager.setUserAndCountryProgram(user)
        }
    }
    
    //MARK: Class Methods
    
    func checkIfIsSyriaUser() {
        URIPCheckManager.getCountryCodeByIP { (countryCode) in }
    }
    
    class func updateUserDataInRapidPro(_ user:URUser) {
        
        URRapidProContactUtil.buildRapidProUserDictionaryWithContactFields(user, country: URCountry(code:"")) { (rapidProUserDictionary:NSDictionary) -> Void in
            URRapidProManager.saveUser(user, country: URCountry(code:user.country!),setupGroups: false, completion: { (response) -> Void in
                URRapidProContactUtil.rapidProUser = NSMutableDictionary()
                URRapidProContactUtil.groupList = []
                print(response)
            })
        }
        
    }
    
    func setupUI() {
        
        self.lbOr.text = "login_or".localized
        self.btSkipLogin.setTitle("login_skip".localized, for: UIControlState())
        self.btSignUp.setTitle("login_sign_up".localized, for: UIControlState())
        self.btLogin.setTitle("login".localized, for: UIControlState())
        self.btFacebookLogin.setTitle("login_facebook".localized, for: UIControlState())
        self.btTwitterLogin.setTitle("login_twitter".localized, for: UIControlState())
        self.btGooglePlusLogin.setTitle("login_google".localized, for: UIControlState())
        
        self.btSignUp.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    //MARK: Button Events
    
    @IBAction func btSkipLoginTapped(_ sender: AnyObject) {
        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
    }
    
    @IBAction func btTwitterTapped(_ sender: AnyObject) {
        /*
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            URUserLoginManager.loginWithTwitter { (user) -> Void in
                MBProgressHUD.hide(for: self.view, animated: true)
                if user == nil {
                    
                    let alert = UIAlertController(title: nil, message: "twitter_error_message".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        UIApplication.shared.openURL(URL(string:"prefs:root=TWITTER")!)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }else if user!.key == nil {
                    self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user!, updateMode:false),animated:true)
                }else {
                    URLoginViewController.updateUserDataInRapidPro(user!)
                    URUserLoginManager.setUserAndCountryProgram(user!)
                }
            }
        }
         */
    }
    
    @IBAction func btLoginTapped(_ sender: AnyObject) {
        
        self.navigationController!.pushViewController(URLoginCredentialsViewController(), animated: true)
        
    }
    @IBAction func btFacebookTapped(_ sender: AnyObject) {
        
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            URUserLoginManager.loginWithFacebook(self) { (user) -> Void in
                MBProgressHUD.hide(for: self.view, animated: true)
                
                guard let user = user else {
                    ISAlertMessages.displaySimpleMessage("unknown_error".localized, fromController: self)
                    return
                }
                
                if user.key == nil {
                     self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user,updateMode:false),animated:true)
                }else{
                    URLoginViewController.updateUserDataInRapidPro(user)
                    URUserLoginManager.setUserAndCountryProgram(user)
                }
                
            }
        }
    }
    @IBAction func btGooglePlusTapped(_ sender: AnyObject) {
        
        if URSettings.checkIfTermsIsAccepted(termsViewController, viewController: self) == true {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            userLoginManager.loginViewController = self
            userLoginManager.loginWithGoogle(self)
            userLoginManager.delegate = self
        }
        
    }
    
    @IBAction func btSignUpTapped(_ sender: AnyObject) {
        self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.SIGNUP_PRIMARY), animated: true)
    }
    
}
