//
//  URPollTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol URClosedPollTableViewControllerDelegate {
    func tableViewCellDidTap(_ cell:URClosedPollTableViewCell,isIPad:Bool)
}

class URClosedPollTableViewController: UIViewController, URPollManagerDelegate, UITableViewDelegate, UITableViewDataSource, URCurrentPollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    let pollManager = URPollManager()
    var headerCell:URCurrentPollView!
    var pollList:[URPoll] = []
    
    var responses:[URRulesetResponse] = []
    
    var contact:URContact?
    var currentFlow:URFlowDefinition?
    var currentActionSet:URFlowActionSet?
    var currentRuleset:URFlowRuleset?
    
    var delegate:URClosedPollTableViewControllerDelegate?
    
    init() {
        super.init(nibName: "URClosedPollTableViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHeaderCell()
        
        self.pollList = []
        pollManager.delegate = self
        pollManager.getPolls()
        
        self.title = "main_polls".localized
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        URIPCheckManager.getCountryCodeByIP { (countryCode) in}
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Poll Results List")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }

        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !URRapidProManager.sendingAnswers {
            loadCurrentFlow()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pollList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URClosedPollTableViewCell.self), for: indexPath) as! URClosedPollTableViewCell
        
        cell.setupCellWithData(self.pollList[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? URClosedPollTableViewCell
        
        if let delegate = self.delegate {
            delegate.tableViewCellDidTap(cell!,isIPad: URConstant.isIpad)
        }        
    }
    
    //MARK: PollManager Delegate
    @objc fileprivate func reloadPolls() {
        self.pollList = []
        self.tableView.reloadData()
        self.tableView.setRefreshControlTo(animate: true)
        self.pollManager.getPolls()
    }
    
    func newPollReceived(_ poll: URPoll) {
        self.tableView.setRefreshControlTo(animate: false)
        self.pollList.insert(poll, at: 0)
        self.tableView.reloadData()
        self.fitScrollSize()
    }
    
    func newPollResultReceived(_ pollResult: URPollResult) {
        
    }
    
    //MARK: URCurrentPollViewDelegate
    
    func onBoundsChanged() {
        if let _ = URUser.activeUser() {
            reloadCurrentFlowSection()
        }
    }
    
    //MARK: Class Methods    
    
    func moveToNextStep() {
        
        if self.currentActionSet != nil && headerCell.getResponse() == nil && currentRuleset != nil {
            UIAlertView(title: nil, message: "answer_poll_choose_error".localized, delegate: self, cancelButtonTitle: "OK").show()
            return
        }else {
            if let response = headerCell.getResponse() {
                responses.append(response)
            }
            
            setupNextStep(headerCell.flowRule?.destination ?? currentActionSet?.destination)
            reloadCurrentFlowSection()
        }

    }
    
    fileprivate func setupHeaderCell() {
        headerCell = Bundle.main.loadNibNamed("URCurrentPollView", owner: 0, options: nil)?[0] as! URCurrentPollView
        headerCell.viewController = self
        headerCell.btNext.addTarget(self, action: #selector(moveToNextStep), for: UIControlEvents.touchUpInside)
    }
    
    fileprivate func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.register(UINib(nibName: "URClosedPollTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URClosedPollTableViewCell.self))
        self.tableView.separatorColor = UIColor.groupTableViewBackground
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 220;
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.separatorInset = UIEdgeInsets.zero
        //self.tableView.addRefreshControl(target: self, selector: #selector(reloadPolls))
        URNavigationManager.setupNavigationBarWithType(.blue)
    }
    
    fileprivate func loadCurrentFlow() {
        URRapidProManager.getContact(URUser.activeUser()!, completion: { (contact) -> Void in
            self.contact = contact
            URRapidProManager.getFlowRuns(contact, completion: { (flowRuns: [URFlowRun]?) -> Void in
                if let flowRuns = flowRuns {
                    if ((!flowRuns.isEmpty) && URFlowManager.isFlowActive(flowRuns[0])) {
                        URRapidProManager.getFlowDefinition(flowRuns[0].flow.uuid, completion: {
                            (flowDefinition: URFlowDefinition) -> Void in
                            self.currentFlow = flowDefinition
                            self.setupNextStep(self.currentFlow!.entry)
                            self.reloadCurrentFlowSection()
                        })
                    }
                }
            })
        })
    }
    
    fileprivate func setupNextStep(_ destination:String?) {
        self.currentActionSet = URFlowManager.getFlowActionSetByUuid(currentFlow!, destination: destination, currentActionSet: currentActionSet)
        self.currentRuleset = URFlowManager.getRulesetForAction(currentFlow!, actionSet: currentActionSet)
    }
    
    fileprivate func reloadCurrentFlowSection() {
        
        headerCell.delegate = self
        
        var currentPollHeight:CGFloat = 0.0
        
        if !URFlowManager.isLastActionSet(currentActionSet) {
            headerCell.setupData(currentFlow!, flowActionSet: currentActionSet!, flowRuleset: currentRuleset, contact: contact!)
            currentPollHeight = headerCell.getCurrentPollHeight()
            
        }else if currentActionSet == nil {
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "message_send_poll".localized
            
            URRapidProManager.sendRulesetResponses(URUser.activeUser()!, responses: responses, completion: { () -> Void in
                
                DispatchQueue.main.async {
                    self.responses = []
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
            
            updateTopViewHeight(0)
            headerCell.removeFromSuperview()
            self.view.endEditing(true)
            
        }else{
            headerCell.setupDataWithNoAnswer(currentFlow, flowActionSet: currentActionSet, flowRuleset: currentRuleset, contact: contact)
            
            currentPollHeight = headerCell.getCurrentPollHeight() - 30
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "message_send_poll".localized
            
            URRapidProManager.sendRulesetResponses(URUser.activeUser()!, responses: responses, completion: { () -> Void in
                
                DispatchQueue.main.async {
                    self.responses = []
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
        }
        
        headerCell.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: currentPollHeight)
        updateTopViewHeight(currentPollHeight)
        fitScrollSize()
    }
    
    fileprivate func updateTopViewHeight(_ newHeight:CGFloat) {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: -64)
        topViewHeight.constant = newHeight
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func fitScrollSize() {
        if topView.subviews.count == 0 {
            topView.addSubview(headerCell)
        }
        
        var scrollViewHeight = topViewHeight.constant
        scrollViewHeight = scrollViewHeight + self.tableView.contentSize.height
        
        self.contentViewHeight.constant = scrollViewHeight
        
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width,height: scrollViewHeight)
        self.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0)
        
        self.view.layoutIfNeeded()
    }
}
