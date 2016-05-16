//
//  URPollContributionModalViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 16/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore

class URPollContributionModalViewController: ISModalViewController {

    @IBOutlet weak var txtContribute: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var btSend: UIButton!
    
    let pollContributionTableViewController = URPollContributionTableViewController()
    
    var poll:URPoll!
    
    init() {
        super.init(nibName: "URPollContributionModalViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView.layer.cornerRadius = 5
        pollContributionTableViewController.poll = self.poll
        displayContentController(self.pollContributionTableViewController)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        pollContributionTableViewController.view.frame = CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
    }

    //MARK: Class Methods
    
    func sendContribution(textField:UITextField) {
        if !textField.text!.isEmpty {
            
            if URUserManager.userHasPermissionToAccessTheFeature(false) {
                
                let user = URUser()
                user.key = URUser.activeUser()!.key
                
                let contribution = URContribution()
                contribution.content = textField.text!
                contribution.author = user
                contribution.createdDate = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
                
                URContributionManager.savePollContribution(poll.key, contribution: contribution, completion: { (success) -> Void in
                    URUserManager.incrementUserContributions(user.key)
//                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: self.listContribution.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    textField.text = ""
                    textField.resignFirstResponder()
                })
                
            }else {
                if URUserManager.userHasPermissionToAccessTheFeature(false) == false {
                    let alertController = UIAlertController(title: nil, message: "feature_without_permission".localized, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: {})
                }
            }
            
        }
    }
    
    func displayContentController(content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
        self.contentView.insertSubview(content.view, atIndex: 0)
        content.didMoveToParentViewController(self)
    }
    
    //MARK: Button Events
    
    @IBAction func btSendTapped(sender: AnyObject) {
        sendContribution(self.txtContribute)
    }
    
    @IBAction func btDismissTapped(sender: AnyObject) {
        self.close { (finish) in }
    }
    
}
