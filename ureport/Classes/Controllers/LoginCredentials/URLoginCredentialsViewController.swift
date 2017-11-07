//
//  URLoginCredentialsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//
import UIKit
import Firebase
import MBProgressHUD
import IlhasoftCore

class URLoginCredentialsViewController: UIViewController {
    
    @IBOutlet weak var btForgotPassword: UIButton!
    @IBOutlet weak var btLogin: UIButton!
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var rememberMeLbl: UILabel!
    
    var appDelegate:AppDelegate!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "URLoginCredentialsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Login Credentials")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    //MARK: Button Events
    @IBAction func btForgotPasswordTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(URForgotPasswordViewController(), animated: true)
    }
    
    @IBAction func btLoginTapped(_ sender: AnyObject) {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if let textfield = self.view.findTextFieldEmptyInView(self.view) {
            MBProgressHUD.hide(for: self.view, animated: true)
            UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textfield.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        self.view.endEditing(true)
        
        URUserLoginManager.login(self.txtLogin.text!,password: self.txtPassword.text!, completion: { (FAuthenticationError,success) -> Void in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            if success {
                self.saveEmailAddress()
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            }else {
                UIAlertView(title: nil, message: "login_password_error".localized, delegate: self, cancelButtonTitle: "OK").show()
            }
        })
    }
    
    @IBAction func rememberMeSwitchChanged(_ sender: Any) {
        
        if rememberMeSwitch.isOn {
            rememberMeLbl.text = "Remember me"
        } else {
            rememberMeLbl.text = "Don't remember me"
        }
    }
    
    
    //MARK: Class Methods
    
    func setupUI() {
        self.btLogin.setTitle("login".localized, for: UIControlState())
        self.btForgotPassword.setTitle("login_forgot_password".localized, for: UIControlState())
        #if ONTHEMOVE
            self.btLogin.backgroundColor = URConstant.Color.PRIMARY
        #endif
        
        self.txtLogin.placeholder = "login_email".localized
        self.txtPassword.placeholder = "login_password".localized
        
        if let cachedEmail = UserDefaults.standard.string(forKey: "CachedEmailAddress") {
            self.txtLogin.text = cachedEmail
        }
        
        self.navigationController?.navigationBar.barTintColor = URConstant.Color.LOGIN_PRIMARY
    }
    
    private func saveEmailAddress() {
        if rememberMeSwitch.isOn {
            if let email = txtLogin.text {
                UserDefaults.standard.set(email, forKey: "CachedEmailAddress")
            }
        }
    }
}
