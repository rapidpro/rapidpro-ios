//
//  URLoginViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 07/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URLoginViewController: UIViewController, URUserLoginManagerDelegate {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btLogin: UIButton!
    @IBOutlet weak var btFacebookLogin: UIButton!
    @IBOutlet weak var btGooglePlusLogin: UIButton!
    @IBOutlet weak var btSignUp: UIButton!
    @IBOutlet weak var btTwitterLogin: UIButton!
    @IBOutlet weak var btSkipLogin: UIButton!
    
    var appDelegate:AppDelegate!
    var userLoginManager:URUserLoginManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        userLoginManager = URUserLoginManager()
        
        setupUI()
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
    
    //MARK: URUserLoginManagerDelegate
    
    func userHasLoggedInGoogle(user: URUser) {
        ProgressHUD.dismiss()
        if user.key.isEmpty {
            print("error ao logar com google")
        }else{
            
            URUserManager.getByKey(user.key, completion: { (userById,exists) -> Void in
                if exists {
                    URUserLoginManager.setUserAndCountryProgram(userById!)
                }else {
                    self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user, updateMode:false),animated:true)
                }
            })
        }
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        self.btSignUp.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }
    
    //MARK: Button Events
    
    @IBAction func btSkipLoginTapped(sender: AnyObject) {
        URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
    }
    
    @IBAction func btTwitterTapped(sender: AnyObject) {
        
        ProgressHUD.show(nil)
        URUserLoginManager.loginWithTwitter { (user) -> Void in
            ProgressHUD.dismiss()
            if user == nil || user!.key.isEmpty {
                print("error ao logar com twitter")
            }else{
                ProgressHUD.show(nil)
                URUserManager.getByKey(user!.key, completion: { (userById,exists) -> Void in
                    ProgressHUD.dismiss()
                    if exists {
                        URUserLoginManager.setUserAndCountryProgram(userById!)
                    }else {
                        self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user!, updateMode:false),animated:true)
                    }
                })
            }
        }
        
    }
    
    @IBAction func btLoginTapped(sender: AnyObject) {
        self.navigationController!.pushViewController(URLoginCredentialsViewController(nibName: "URLoginCredentialsViewController", bundle: nil), animated: true)
    }
    @IBAction func btFacebookTapped(sender: AnyObject) {
        ProgressHUD.show(nil)
        URUserLoginManager.loginWithFacebook(self) { (user) -> Void in
            ProgressHUD.dismiss()
            if user == nil || user!.key.isEmpty {
                print("error ao logar com facebook")
                //alert
            }else{
                ProgressHUD.show(nil)
                URUserManager.getByKey(user!.key, completion: { (userById,exists) -> Void in
                    ProgressHUD.dismiss()
                    if exists {
                        URUserLoginManager.setUserAndCountryProgram(userById!)

                    }else {
                        self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.CONFIRM_INFO_PRIMARY,user: user!,updateMode:false),animated:true)
                    }
                })
            }

        }
    }
    @IBAction func btGooglePlusTapped(sender: AnyObject) {
        ProgressHUD.show(nil)
        userLoginManager.loginViewController = self
        userLoginManager.loginWithGoogle(self)        
        userLoginManager.delegate = self
    }
    
    @IBAction func btSignUpTapped(sender: AnyObject) {
        self.navigationController!.pushViewController(URUserRegisterViewController(color: URConstant.Color.SIGNUP_PRIMARY), animated: true)
    }
    
}
