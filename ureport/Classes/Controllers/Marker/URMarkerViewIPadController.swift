//
//  URMarkerViewIPadController.swift
//  ureport
//
//  Created by Daniel Amaral on 05/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore

class URMarkerViewIPadController: ISModalViewController {

    @IBOutlet var viewContent:UIView!
    @IBOutlet var viewController:UIViewController!
    
    let markerTableViewController = URMarkerTableViewController()
    
    init() {
      super.init(nibName: "URMarkerViewIPadController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = viewController as? URAddStoryViewController {
            markerTableViewController.delegate = viewController
        }
        
        displayContentController(markerTableViewController)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.markerTableViewController.view.frame = CGRect(x: 0, y: 0, width: self.viewContent.frame.width, height: self.viewContent.frame.height)
    }
    
    //MARK: Class Methods
    
    func displayContentController(_ content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = CGRect(x: 0, y: 0, width: viewContent.bounds.size.width, height: viewContent.bounds.size.height)
        viewContent.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }

    //MARK: Button Events
    
    @IBAction func btSaveTapped(_ button:UIButton) {
        self.closeWithCompletion { (closed) in            
        }
    }
    
}
