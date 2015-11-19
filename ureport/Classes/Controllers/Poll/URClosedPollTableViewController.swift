//
//  URPollTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URClosedPollTableViewController: UITableViewController, URPollManagerDelegate {
    
    let pollManager = URPollManager()
    var pollList:[URPoll] = []
    
    var currentFlow:URFlowDefinition?
    var currentFlowLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadCurrentFlow()
        
        self.title = "Poll Results".localized
    }
    
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentFlow != nil {
            let headerCell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URCurrentPollTableViewCell.self)) as! URCurrentPollTableViewCell
            headerCell.setupCellWithData(currentFlow!)
            return headerCell.contentView;
        }
        
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pollList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URClosedPollTableViewCell.self), forIndexPath: indexPath) as! URClosedPollTableViewCell
        
        cell.setupCellWithData(self.pollList[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? URClosedPollTableViewCell
        self.navigationController?.pushViewController(URPollResultTableViewController(poll: cell!.poll), animated: true)
    }
    
    //MARK: PollManager Delegate
    
    func newPollReceived(poll: URPoll) {
        self.pollList.insert(poll, atIndex: 0)
        self.tableView.reloadData()
    }
    
    func newPollResultReceived(pollResult: URPollResult) {
        
    }
    
    //MARK: Class Methods
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.registerNib(UINib(nibName: "URClosedPollTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URClosedPollTableViewCell.self))
        self.tableView.registerNib(UINib(nibName: "URCurrentPollTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URCurrentPollTableViewCell.self))
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 220;
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 220
        
        pollManager.delegate = self
        URNavigationManager.setupNavigationBarWithType(.Blue)
        pollManager.getPolls()
    }
    
    private func loadCurrentFlow() {
        URRapidProManager.getContact(URUser.activeUser()!, completion: { (contact) -> Void in
            print(contact.uuid)
            URRapidProManager.getFlowRuns(contact, completion: { (flowRuns: [URFlowRun]) -> Void in
                if !flowRuns.isEmpty && URFlowManager.isFlowActive(flowRuns[0]) {
                    URRapidProManager.getFlowDefinition(flowRuns[0].flow_uuid, completion: {
                        (flowDefinition: URFlowDefinition) -> Void in
                        self.currentFlow = flowDefinition
                        self.reloadCurrentFlowSection()
                    })
                }
            })
        })
    }
    
    private func reloadCurrentFlowSection() {
        self.tableView.beginUpdates()
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
    }
    
}
