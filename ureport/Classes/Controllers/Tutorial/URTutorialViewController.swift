//
//  URTutorialViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 20/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URTutorialViewController: UIViewController, ISScrollViewPageDelegate {

    @IBOutlet var scrollViewTutorial: ISScrollViewPage!
    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var btGetStarted:UIButton!
    
    let tutoView1 = NSBundle.mainBundle().loadNibNamed("URTutoView", owner: 0, options: nil)[0] as? URTutoView
    let tutoView2 = NSBundle.mainBundle().loadNibNamed("URTutoView", owner: 0, options: nil)[0] as? URTutoView
    let tutoView3 = NSBundle.mainBundle().loadNibNamed("URTutoView", owner: 0, options: nil)[0] as? URTutoView
    
    init() {
        super.init(nibName: "URTutorialViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewPage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayout()
        
        var frame = self.scrollViewTutorial.bounds
        frame.size.height = frame.size.height - UIApplication.sharedApplication().statusBarFrame.height
        self.scrollViewTutorial.contentSize = CGSizeMake(self.scrollViewTutorial.contentSize.width, frame.size.height)
    }
    
    //MARK: Class Methods
    
    func setupScrollViewPage() {
        scrollViewTutorial.scrollViewPageDelegate = self;
        scrollViewTutorial.setFillContent(true)
        scrollViewTutorial.setEnableBounces(false)
        scrollViewTutorial.setPaging(true)
        scrollViewTutorial.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
        
        scrollViewTutorial.setCustomViews([tutoView1!,tutoView2!,tutoView3!])        
        
    }
    
    func setupLayout() {
        
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.scrollViewTutorial.frame.height)
        
        tutoView1!.frame = frame
        tutoView2!.frame = frame
        tutoView3!.frame = frame
        
        tutoView1!.imgTutorial.image = UIImage(named: "img_intro1")
        tutoView2!.imgTutorial.image = UIImage(named: "img_intro2")
        tutoView3!.imgTutorial.image = UIImage(named: "img_intro3")
        
        tutoView1!.lbTitle.text = "Create Stories"
        tutoView1!.lbText.text = "Amplify your voice, talk about what's happening in your community creating stories and contributing to reports of other users."
        
        tutoView2!.lbTitle.text = "Polls"
        tutoView2!.lbText.text = "Polls on community interest topics will be sent periodically to be answered."

        tutoView3!.lbTitle.text = "Chat"
        tutoView3!.lbText.text = "Contact with other users and see what they say out there."
        
    }
    
    func scrollViewPageDidChanged(scrollViewPage: ISScrollViewPage, index: Int) {
        self.pageControl.currentPage = index
    }
    
    //MARK: Button Events
    
    @IBAction func btGetStartedTapped(button:UIButton) {
    
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    
    }
    
}
