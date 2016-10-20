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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)        
        pollManager.delegate = self
        
        if let poll = poll {
            self.pollResultList = []
            pollManager.getPollsResults(poll.key)
        }
        
        setupTableView()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Poll Results")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pollResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URPollResultTableViewCell.self), for: indexPath) as! URPollResultTableViewCell
        
        cell.setupCellWithData(self.pollResultList[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as? URPollResultTableViewCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {

        let pollResult = pollResultList[(indexPath as NSIndexPath).row]
        
        if pollResult.type == "Choices" {
            return 189 + CGFloat(pollResult.results.count * 61)
        }else {
            return 444
        }
        
    }
    
    //MARK: PollManager Delegate
    
    func newPollReceived(_ poll: URPoll) {
        
    }
    
    func newPollResultReceived(_ pollResult: URPollResult) {
        pollResultList.insert(pollResult, at: pollResultList.count)        
        self.tableView.reloadData()
    }
    
    //MARK: Class Methods
    
    func openPollContribution() {
        pollContributionModal.poll = self.poll
        pollContributionModal.show(true, inViewController: self)
    }
    
    func reloadWithPoll(_ poll:URPoll) {
        self.pollResultList = []
        self.poll = poll
        pollManager.getPollsResults(poll.key)
    }
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, URConstant.isIpad ? 49 : 0, 0);
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.register(UINib(nibName: "URPollResultTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URPollResultTableViewCell.self))
        self.tableView.separatorColor = UIColor.groupTableViewBackground
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    //MARK: Button Events
    
    @IBAction func btCommentTapped(_ button:UIButton) {
        openPollContribution()
    }
}
