//
//  URTutorialViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 20/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import ISScrollViewPageSwift

class URTutorialViewController: UIViewController, ISScrollViewPageDelegate {

    @IBOutlet var scrollViewTutorial: ISScrollViewPage!
    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var btGetStarted:UIButton!
    
    let tutoView1 = Bundle.main.loadNibNamed("URTutoView", owner: 0, options: nil)?[0] as? URTutoView
    let tutoView2 = Bundle.main.loadNibNamed("URTutoView", owner: 0, options: nil)?[0] as? URTutoView
    let tutoView3 = Bundle.main.loadNibNamed("URTutoView", owner: 0, options: nil)?[0] as? URTutoView
    
    init() {
        super.init(nibName: "URTutorialViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Tutorial")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = UIColor(rgba: "#00cff6").colorWithAlphaComponent(1)
        
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        setupScrollViewPage()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayout()
        
        var frame = self.scrollViewTutorial.bounds
        frame.size.height = frame.size.height - UIApplication.shared.statusBarFrame.height
        self.scrollViewTutorial.contentSize = CGSize(width: self.scrollViewTutorial.contentSize.width, height: frame.size.height)
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
        
        self.btGetStarted.setTitle("get_started_title".localized, for: UIControlState())
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.scrollViewTutorial.frame.height)
        
        tutoView1!.frame = frame
        tutoView2!.frame = frame
        tutoView3!.frame = frame
        
        tutoView1!.imgTutorial.image = UIImage(named: "img_intro1")
        tutoView2!.imgTutorial.image = UIImage(named: "img_intro2")
        tutoView3!.imgTutorial.image = UIImage(named: "img_intro3")
        
        tutoView1!.backgroundColor = UIColor.clear
        tutoView2!.backgroundColor = UIColor.clear
        tutoView3!.backgroundColor = UIColor.clear
        
        tutoView1!.lbTitle.text = "tutorial_title1".localized
        tutoView1!.lbText.text = "tutorial_description1".localized
        
        tutoView2!.lbTitle.text = "tutorial_title2".localized
        tutoView2!.lbText.text = "tutorial_description2".localized

        tutoView3!.lbTitle.text = "tutorial_title3".localized
        tutoView3!.lbText.text = "tutorial_description3".localized
        
    }
    
    func scrollViewPageDidScroll(_ scrollView: UIScrollView) {        
        
    }
    
    func scrollViewPageDidChanged(_ scrollViewPage: ISScrollViewPage, index: Int) {
        self.pageControl.currentPage = index
    }
    
    //MARK: Button Events
    
    @IBAction func btGetStartedTapped(_ button:UIButton) {
    
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    
    }
    
}
