//
//  URForgotPasswordViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URForgotPasswordViewController: UIViewController {

    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btSendPassword: UIButton!
    @IBOutlet weak var viewEmail: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Forgot Password")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    //MARK: Button Events
    
    @IBAction func btSendPasswordTapped(sender: AnyObject) {
        
        if self.txtEmail.text!.isEmpty {
            UIAlertView(title: nil, message: "Put your email", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        self.view.endEditing(true)
        ProgressHUD.show(nil)
        URUserLoginManager.resetPassword(self.txtEmail.text!, completion: { (success:Bool) -> Void in
            ProgressHUD.dismiss()
            if success == true {
                UIAlertView(title: nil, message: "The password has sent to your email.", delegate: self, cancelButtonTitle: "OK").show()
            }else {
                UIAlertView(title: nil, message: "Sorry, unexpected error try again.", delegate: self, cancelButtonTitle: "OK").show()
            }
        })
    }

    //MARK: Class Methods
    


}
