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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Tutorial")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = UIColor(rgba: "#00cff6").colorWithAlphaComponent(1)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        setupScrollViewPage()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
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
        
        self.btGetStarted.setTitle("get_started_title".localized, forState: UIControlState.Normal)
        
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.scrollViewTutorial.frame.height)
        
        tutoView1!.frame = frame
        tutoView2!.frame = frame
        tutoView3!.frame = frame
        
        tutoView1!.imgTutorial.image = UIImage(named: "img_intro1")
        tutoView2!.imgTutorial.image = UIImage(named: "img_intro2")
        tutoView3!.imgTutorial.image = UIImage(named: "img_intro3")
        
        tutoView1!.backgroundColor = UIColor.clearColor()
        tutoView2!.backgroundColor = UIColor.clearColor()
        tutoView3!.backgroundColor = UIColor.clearColor()
        
        tutoView1!.lbTitle.text = "tutorial_title1".localized
        tutoView1!.lbText.text = "tutorial_description1".localized
        
        tutoView2!.lbTitle.text = "tutorial_title2".localized
        tutoView2!.lbText.text = "tutorial_description2".localized

        tutoView3!.lbTitle.text = "tutorial_title3".localized
        tutoView3!.lbText.text = "tutorial_description3".localized
        
    }
    
    func scrollViewPageDidScroll(scrollView: UIScrollView) {        
        
    }
    
    func scrollViewPageDidChanged(scrollViewPage: ISScrollViewPage, index: Int) {
        self.pageControl.currentPage = index
    }
    
    //MARK: Button Events
    
    @IBAction func btGetStartedTapped(button:UIButton) {
    
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    
    }
    
}
