//
//  URAboutViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URAboutViewController: UIViewController {

    @IBOutlet weak var lbVoiceMatters: UILabel!
    @IBOutlet weak var btFacebook: UIButton!
    @IBOutlet weak var btTwitter: UIButton!
    @IBOutlet weak var lbAboutContent: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = "About".localized
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "About")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        scrollView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        self.btTwitter.layer.cornerRadius = self.btTwitter.frame.size.height / CGFloat(2.0)
        self.btFacebook.layer.cornerRadius = self.btTwitter.frame.height / CGFloat(2.0)
    }
    
    //MARK: Button Events
    
    @IBAction func btTwitterTapped(sender: AnyObject) {
        if let twitter =  URCountryProgramManager.activeCountryProgram()?.twitter {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.twitter.com/\(twitter)")!)
        }else {
            UIAlertView(title: "", message: "twitter_account".localized, delegate: self, cancelButtonTitle: "OK").show()
        }
    }
    
    @IBAction func btFacebookTapped(sender: AnyObject) {
        if let facebook =  URCountryProgramManager.activeCountryProgram()?.facebook {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.twitter.com/\(facebook)")!)
        }else {
            UIAlertView(title: "", message: "This country program doesn't have facebook account yet", delegate: self, cancelButtonTitle: "OK").show()
        }
    }
}
