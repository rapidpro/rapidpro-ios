//
//  URLoginCredentialsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

class URLoginCredentialsViewController: UIViewController {

    @IBOutlet weak var btForgotPassword: UIButton!
    @IBOutlet weak var btLogin: UIButton!
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var viewPassword: UIView!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Login Credentials")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()        
    }
    
    //MARK: Button Events
    @IBAction func btForgotPasswordTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(URForgotPasswordViewController(nibName:"URForgotPasswordViewController",bundle:nil), animated: true)
    }

    @IBAction func btLoginTapped(sender: AnyObject) {
        
        if let textfield = self.view.findTextFieldEmptyInView(self.view) {
            UIAlertView(title: nil, message: "\(textfield.placeholder!) is empty", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        self.view.endEditing(true)
        ProgressHUD.show(nil)
        URUserLoginManager.login(self.txtLogin.text!,password: self.txtPassword.text!, completion: { (FAuthenticationError,success) -> Void in
        ProgressHUD.dismiss()
            if success {                
                URNavigationManager.setupNavigationControllerWithMainViewController(URMainViewController())
            }else {
                UIAlertView(title: nil, message: "Login/Password incorrect", delegate: self, cancelButtonTitle: "OK").show()
            }
        })
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = URConstant.Color.LOGIN_PRIMARY
    }
    
}
