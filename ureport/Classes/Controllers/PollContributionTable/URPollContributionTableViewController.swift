//
//  URMarkerTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPollContributionTableViewController: UITableViewController, URContributionManagerDelegate, URContributionTableViewCellDelegate {
    
    var poll:URPoll!
    var listContribution:[URContribution] = []
    var contributionManager = URContributionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        contributionManager.getPollContributions(poll.key)
        contributionManager.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Poll Contribution")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    //MARK: URContributionManagerDelegate
    
    func newContributionReceived(contribution: URContribution) {
        self.listContribution.append(contribution)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.listContribution.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func contributionTableViewCellDeleteButtonTapped(cell: URContributionTableViewCell) {
        let alert = UIAlertController(title: nil, message: "message_remove_chat_message".localized, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "label_remove".localized, style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            let indexPath = self.tableView.indexPathForCell(cell)!
            self.listContribution.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            URContributionManager.removePollContribution(self.poll.key, contributionKey: cell.contribution.key)
        }))
        
        if URConstant.isIpad {
            alert.modalPresentationStyle = UIModalPresentationStyle.Popover
            alert.popoverPresentationController!.sourceView = cell.btDelete
            alert.popoverPresentationController!.sourceRect = cell.btDelete.bounds
        }
        
        alert.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: UIAlertActionStyle.Cancel, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listContribution.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URContributionTableViewCell.self), forIndexPath: indexPath) as! URContributionTableViewCell
        
        cell.setupCellWith(self.listContribution[indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    //MARK: Class Methods
    
    func setupTableView() {
        
//        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URContributionTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URContributionTableViewCell.self))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 68.0
    }
    
}
