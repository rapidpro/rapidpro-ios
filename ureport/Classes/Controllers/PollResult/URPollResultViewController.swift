//
//  URPollResultTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 22/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URPollResultViewController: UIViewController, URPollManagerDelegate {

    @IBOutlet var tableView:UITableView!
    @IBOutlet var btComment:UIButton!
    
    let pollManager = URPollManager()
    var pollResultList:[URPollResult] = []
    
    var poll:URPoll?
    var pollContributionModal = URPollContributionModalViewController()
    
    init(poll:URPoll) {
        self.poll = poll
        super.init(nibName: "URPollResultViewController", bundle: nil)
    }

    init() {
        super.init(nibName:"URPollResultViewController", bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "poll_results".localized
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)        
        pollManager.delegate = self
        
        if let poll = poll {
            self.pollResultList = []
            pollManager.getPollsResults(poll.key)
        }
        
        setupTableView()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Poll Results")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pollResultList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URPollResultTableViewCell.self), forIndexPath: indexPath) as! URPollResultTableViewCell
        
        cell.setupCellWithData(self.pollResultList[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as? URPollResultTableViewCell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let pollResult = pollResultList[indexPath.row]
        
        if pollResult.type == "Choices" {
            return 189 + CGFloat(pollResult.results.count * 61)
        }else {
            return 444
        }
        
    }
    
    //MARK: PollManager Delegate
    
    func newPollReceived(poll: URPoll) {
        
    }
    
    func newPollResultReceived(pollResult: URPollResult) {
        pollResultList.insert(pollResult, atIndex: pollResultList.count)        
        self.tableView.reloadData()
    }
    
    //MARK: Class Methods
    
    func openPollContribution() {
        pollContributionModal.poll = self.poll
        pollContributionModal.show(true, inViewController: self)
    }
    
    func reloadWithPoll(poll:URPoll) {
        self.pollResultList = []
        self.poll = poll
        pollManager.getPollsResults(poll.key)
    }
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, URConstant.isIpad ? 49 : 0, 0);
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.registerNib(UINib(nibName: "URPollResultTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URPollResultTableViewCell.self))
        self.tableView.separatorColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorInset = UIEdgeInsetsZero
    }
    
    //MARK: Button Events
    
    @IBAction func btCommentTapped(button:UIButton) {
        openPollContribution()
    }
}
