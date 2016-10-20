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
        
        if let textfield = self.view.findTextFieldEmptyInView(self.view) {
            UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: [textfield.placeholder!]), delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        self.view.endEditing(true)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URUserLoginManager.login(self.txtLogin.text!,password: self.txtPassword.text!, completion: { (FAuthenticationError,success) -> Void in
        MBProgressHUD.hide(for: self.view, animated: true)
            if success {                
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            }else {
                UIAlertView(title: nil, message: "login_password_error".localized, delegate: self, cancelButtonTitle: "OK").show()
            }
        })
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        self.btLogin.setTitle("login".localized, for: UIControlState())
        self.btForgotPassword.setTitle("login_forgot_password".localized, for: UIControlState())
        
        self.txtLogin.placeholder = "login_email".localized
        self.txtPassword.placeholder = "login_password".localized
        
        self.navigationController?.navigationBar.barTintColor = URConstant.Color.LOGIN_PRIMARY
    }
    
}
