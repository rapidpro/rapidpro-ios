//
//  URForgotPasswordViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import MBProgressHUD

class URForgotPasswordViewController: UIViewController {

    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btSendPassword: UIButton!
    @IBOutlet weak var viewEmail: UIView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "URForgotPasswordViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btSendPassword.setTitle("answer_polls_respond".localized, for: UIControlState())
        self.lbMessage.text = "info_forgot_password".localized
        self.txtEmail.placeholder = "login_email".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Forgot Password")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
    }
    
    //MARK: Button Events
    
    @IBAction func btSendPasswordTapped(_ sender: AnyObject) {
        
        if self.txtEmail.text!.isEmpty {
            UIAlertView(title: nil, message: String(format: "is_empty".localized, arguments: ["login_email".localized]), delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        self.view.endEditing(true)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URUserLoginManager.resetPassword(self.txtEmail.text!, completion: { (success:Bool) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            if success == true {
                UIAlertView(title: nil, message: "error_email_check".localized, delegate: self, cancelButtonTitle: "OK").show()
            }else {
                UIAlertView(title: nil, message: "error_no_internet".localized, delegate: self, cancelButtonTitle: "OK").show()
            }
        })
    }

    //MARK: Class Methods
    


}
