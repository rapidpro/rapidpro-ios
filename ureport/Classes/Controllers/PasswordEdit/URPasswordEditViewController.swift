//
//  URPasswordEditViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 05/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPasswordEditViewController: UIViewController {

    
    @IBOutlet weak var lbConfirmBelow: UILabel!
    @IBOutlet weak var btConfirm: ISRoundedButton!
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Password Edit")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        self.txtCurrentPassword.placeholder = "old_password_title".localized
        self.txtNewPassword.placeholder = "new_password".localized
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)        
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        URNavigationManager.setupNavigationBarWithType(.Blue)
    }    

    //MARK: Button Events
    
    @IBAction func btConfirmTapped(sender: AnyObject) {
        ProgressHUD.show(nil)
        URFireBaseManager.sharedInstance().changePasswordForUser(URUser.activeUser()?.email, fromOld: self.txtCurrentPassword.text, toNew: self.txtNewPassword.text) { (error:NSError?) -> Void in
                ProgressHUD.dismiss()
                self.view.endEditing(true)
            if error != nil {
                UIAlertView(title: nil, message: "An error has occurred, try again!", delegate: self, cancelButtonTitle: "OK").show()
            }else {
                UIAlertView(title: nil, message: "Your password has changed!", delegate: self, cancelButtonTitle: "OK").show()
                URNavigationManager.navigation.popViewControllerAnimated(true)
            }
        }
        
    }
    
}
