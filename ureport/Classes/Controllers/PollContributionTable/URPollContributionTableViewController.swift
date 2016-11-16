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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Poll Contribution")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
    }
    
    //MARK: URContributionManagerDelegate
    
    func newContributionReceived(_ contribution: URContribution) {
        self.listContribution.append(contribution)
        self.tableView.insertRows(at: [IndexPath(row: self.listContribution.count - 1, section: 0)], with: UITableViewRowAnimation.fade)
    }
    
    func contributionTableViewCellDeleteButtonTapped(_ cell: URContributionTableViewCell) {
        let alert = UIAlertController(title: nil, message: "message_remove_chat_message".localized, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "label_remove".localized, style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            let indexPath = self.tableView.indexPath(for: cell)!
            self.listContribution.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            URContributionManager.removePollContribution(self.poll.key, contributionKey: cell.contribution.key!)
        }))
        
        if URConstant.isIpad {
            alert.modalPresentationStyle = UIModalPresentationStyle.popover
            alert.popoverPresentationController!.sourceView = cell.btDelete
            alert.popoverPresentationController!.sourceRect = cell.btDelete.bounds
        }
        
        alert.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: UIAlertActionStyle.cancel, handler:nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listContribution.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URContributionTableViewCell.self), for: indexPath) as! URContributionTableViewCell
        
        cell.setupCellWith(self.listContribution[(indexPath as NSIndexPath).row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    //MARK: Class Methods
    
    func setupTableView() {
        
//        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "URContributionTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URContributionTableViewCell.self))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 68.0
    }
    
}
