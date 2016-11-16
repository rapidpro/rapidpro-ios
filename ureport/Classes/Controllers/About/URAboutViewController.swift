//
//  URAboutViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class URAboutViewController: UIViewController {

    @IBOutlet weak var lbVoiceMatters: UILabel!
    @IBOutlet weak var btFacebook: UIButton!
    @IBOutlet weak var btTwitter: UIButton!
    @IBOutlet weak var lbAboutContent: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var youtubeView: YTPlayerView?

    init() {
        super.init(nibName: URConstant.isIpad ? "URAboutViewIPadController" : "URAboutViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = "label_about_ureport".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        self.navigationController!.setNavigationBarHidden(false, animated: false)        
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "About")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
        
    }
    
    //MARK: Class Methods
    
    func setupUI() {
        scrollView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        self.btTwitter.layer.cornerRadius = self.btTwitter.frame.size.height / CGFloat(2.0)
        self.btFacebook.layer.cornerRadius = self.btTwitter.frame.height / CGFloat(2.0)
        self.lbAboutContent.text = "about_content".localized
        self.lbVoiceMatters.text = "about_subtitle".localized
        
        self.youtubeView?.load(withVideoId: "pDa9OjtJhSo")
        
    }
    
    //MARK: Button Events
    
    @IBAction func btTwitterTapped(_ sender: AnyObject) {
        if let twitter =  URCountryProgramManager.activeCountryProgram()?.twitter {
            UIApplication.shared.openURL(URL(string: "http://www.twitter.com/\(twitter)")!)
        }
    }
    
    @IBAction func btFacebookTapped(_ sender: AnyObject) {
        if let facebook =  URCountryProgramManager.activeCountryProgram()?.facebook {
            UIApplication.shared.openURL(URL(string: "http://www.facebook.com/\(facebook)")!)
        }
    }
}
