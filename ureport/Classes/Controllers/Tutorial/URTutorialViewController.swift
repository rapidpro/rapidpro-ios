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
        
        tutoView1!.lbTitle.text = "Create Stories"
        tutoView1!.lbText.text = "Amplify your voice, talk about what's happening in your community creating stories and contributing to reports of other users."
        
        tutoView2!.lbTitle.text = "Polls"
        tutoView2!.lbText.text = "Polls on community interest topics will be sent periodically to be answered."

        tutoView3!.lbTitle.text = "Chat"
        tutoView3!.lbText.text = "Contact with other users and see what they say out there."
        
    }
    
    func scrollViewPageDidScroll(scrollView: UIScrollView) {
        
        let value = scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width
        
        print(value)
        
//        if value >= 0 && value <= 0.99 {
//            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
//                    self.view.backgroundColor = UIColor(rgba: "#00cff6")
//                }, completion: nil)
//        }else if value >= 1 && value <= 1.99 {
//            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
//                    self.view.backgroundColor = UIColor(rgba: "#ffa500")
//                }, completion: nil)
//        }else if value >= 2.0 && value <= 3.0 {
//            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
//                    self.view.backgroundColor = UIColor(rgba: "#00d400")
//                }, completion: nil)
//        }
        
    }
    
    func scrollViewPageDidChanged(scrollViewPage: ISScrollViewPage, index: Int) {
        self.pageControl.currentPage = index
    }
    
    //MARK: Button Events
    
    @IBAction func btGetStartedTapped(button:UIButton) {
    
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    
    }
    
}
