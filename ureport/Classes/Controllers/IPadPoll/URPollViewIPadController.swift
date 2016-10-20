//
//  URPollViewIPadController.swift
//  ureport
//
//  Created by Daniel Amaral on 28/04/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URPollViewIPadController: UIViewController, URClosedPollTableViewControllerDelegate {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var contentLeftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var imgMessage: UIImageView!
    
    var poll:URPoll?
    var pollContributionModal = URPollContributionModalViewController()
    
    init() {
        super.init(nibName: "URPollViewIPadController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let closedPollTableViewController = URClosedPollTableViewController()
    let pollResultViewController = URPollResultViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closedPollTableViewController.delegate = self
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.leftView.setNeedsLayout()
        self.leftView.layoutIfNeeded()
        
        self.rightView.setNeedsLayout()
        self.rightView.layoutIfNeeded()
        
        self.contentLeftView.setNeedsLayout()
        self.contentLeftView.layoutIfNeeded()
        
        closedPollTableViewController.view.frame = CGRect(x: 0, y: 0, width: contentLeftView.bounds.size.width, height: contentLeftView.bounds.size.height)
        closedPollTableViewController.tableView.contentSize = CGSize(width: contentLeftView.bounds.size.width, height: closedPollTableViewController.tableView.contentSize.height)
//        pollResultTableViewController.view.frame = CGRect(x: 0, y: 0, width: rightView.bounds.size.width, height: rightView.bounds.size.height)
        pollResultViewController.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
        closedPollTableViewController.onBoundsChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
    }
    
    //MARK: URClosedPollTableViewControllerDelegate
    
    func tableViewCellDidTap(_ cell: URClosedPollTableViewCell, isIPad:Bool) {
        pollResultViewController.btComment.isHidden = false
        self.poll = cell.poll
        pollContributionModal.poll = poll
        self.lbMessage.isHidden = true
        self.imgMessage.isHidden = true
        pollResultViewController.reloadWithPoll(self.poll!)
    }
    
    //MARK: Button Events
    
    @IBAction func btCommentTapped(_ sender: AnyObject) {
        pollContributionModal.show(true, inViewController: self)
    }
    
    
    //MARK: Class Methods
    
    func displayLeftContentController(_ content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = CGRect(x: 0, y: 0, width: contentLeftView.bounds.size.width, height: contentLeftView.bounds.size.height)
        content.view.backgroundColor = UIColor.clear
        self.contentLeftView.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    
    func displayRightContentController(_ content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = CGRect(x: 0, y: 0, width: rightView.bounds.size.width, height: rightView.bounds.size.height - 50)
        self.rightView.insertSubview(content.view, at: 0)
        content.didMove(toParentViewController: self)
    }
    
    func setupUI() {        
        displayLeftContentController(closedPollTableViewController)
        displayRightContentController(pollResultViewController)
        pollResultViewController.tableView.alwaysBounceVertical = false
    }
    
}

