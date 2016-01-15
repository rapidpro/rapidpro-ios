//
//  URProfileViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 25/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

enum TabType {
    case MyStories
    case AnsweredPolls
    case Ranking
}

class URProfileViewController: UIViewController, URPollManagerDelegate, URStoryManagerDelegate, URUserManagerDelegate {
    
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var lbProfileDetails: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btEdit: UIButton!
    @IBOutlet weak var btLogout: UIButton!

    @IBOutlet weak var tableviewMyStories: UITableView!
    @IBOutlet weak var tableviewAnsweredPoll: UITableView!
    @IBOutlet weak var tableviewRanking: UITableView!
    
    @IBOutlet weak var btMyStories: UIButton!
    @IBOutlet weak var btAnsweredPolls: UIButton!
    @IBOutlet weak var btRanking: UIButton!
    
    var tabType:TabType!
    
    var isBtMyStoriesTapped = false
    var isBtAnsweredPollsTapped = false
    var isBtRankingTapped = false
    
    let imgViewHistoryHeight:CGFloat = 188.0
    
    var storyList:[URStory] = []
    var pollList:[URPoll] = []
    var userList:[URUser] = []
    
    var pollManager = URPollManager()
    var storyManager = URStoryManager()
    var userManager = URUserManager()
    var appDelegate:AppDelegate!
    
    init(enterInTabType:TabType) {
        self.tabType = enterInTabType
        super.init(nibName: "URProfileViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadUserInfo()
        selectTabType(self.tabType)
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Clear)
        setupDelegates()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Profile")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: PollManagerDelegate
    
    func newPollReceived(poll: URPoll) {
        self.pollList.insert(poll, atIndex: 0)
        self.tableviewAnsweredPoll.reloadData()
    }
    
    func newPollResultReceived(pollResult: URPollResult) {
    }
    
    //MARK: StoryManagerDelegate
    
    func newStoryReceived(story: URStory) {
        if story.user == URUser.activeUser()?.key {
            storyList.insert(story, atIndex: 0)
            self.tableviewMyStories.reloadData()
        }
    }
    
    //MARK: UserManagerDelegate
    
    func newUserReceived(user: URUser) {
        if (user.points != nil) {
            userList.insert(user, atIndex: 0)
        }
        self.tableviewRanking.reloadData()
    }
    
    //MARK: Class Methods
    
    func selectTabType(type:TabType) {
        switch type {
        case .MyStories:
            btMyStoriesTapped(self.btMyStories)
            break
        case .AnsweredPolls:
            btAnsweredPollsTapped(self.btAnsweredPolls)
            break
        case .Ranking:
            btRankingTapped(self.btRanking)
            break
        }
    }
    
    func setupDelegates() {
        storyList = []
        pollList = []
        userList = []
        pollManager.delegate = self
        pollManager.getPolls()
        storyManager.getStories(false)
        storyManager.delegate = self
        userManager.delegate = self
        userManager.getUsersByPoints()
    }
    
    func setupTableView() {
        self.tableviewAnsweredPoll.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableviewAnsweredPoll.registerNib(UINib(nibName: "URClosedPollTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URClosedPollTableViewCell.self))
         self.tableviewAnsweredPoll.separatorColor = UIColor.clearColor()
        
        self.tableviewAnsweredPoll.rowHeight = UITableViewAutomaticDimension
        self.tableviewAnsweredPoll.estimatedRowHeight = 220.0
        
        self.tableviewMyStories.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableviewMyStories.registerNib(UINib(nibName: "URStoriesTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URStoriesTableViewCell.self))
         self.tableviewMyStories.separatorColor = UIColor.clearColor()
        
        self.tableviewRanking.backgroundColor = UIColor.clearColor()
        self.tableviewRanking.registerNib(UINib(nibName: "URRankingTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URRankingTableViewCell.self))
        self.tableviewRanking.separatorColor = UIColor.clearColor()

    }
    
    func loadUserInfo() {
        if let user = URUser.activeUser() {
            if let picture = user.picture {
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
                self.imageProfile.contentMode = UIViewContentMode.ScaleAspectFit
                self.imageProfile.sd_setImageWithURL(NSURL(string: picture))
            }else{
                self.roundedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
                self.imageProfile.contentMode = UIViewContentMode.Center
                self.imageProfile.image = UIImage(named: "ic_person")
            }
            
            URUserManager.getByKey(user.key, completion: { (user:URUser?, exists:Bool) -> Void in
                if let stories = user!.stories {
                    self.lbProfileDetails.text = String(format: "profile_stories".localized, arguments: [Int(stories)])
                }
                
                if let points = user!.points {
                    self.lbProfileDetails.text = "\(self.lbProfileDetails.text!) \(String(format: "menu_points".localized, arguments: [Int(points)]))"
                }
                
                if self.lbProfileDetails.text!.isEmpty {
                   self.lbProfileDetails.text = "\(String(format: "profile_stories".localized, arguments: [0])) \(String(format: "menu_points".localized, arguments: [0]))"
                }
                
            })
            
        }
    }
    
    func setupUI() {
        self.btEdit.layer.cornerRadius = 4
        self.btLogout.layer.cornerRadius = 4
        self.roundedView.layer.borderWidth = 2
        self.roundedView.layer.borderColor = UIColor.whiteColor().CGColor
        self.tableviewRanking.layer.cornerRadius = 5
        
        self.btEdit.setTitle("label_edit".localized, forState: UIControlState.Normal)
        self.btMyStories.setTitle("label_view_stories".localized, forState: UIControlState.Normal)
        self.btAnsweredPolls.setTitle("profile_answered_polls".localized, forState: UIControlState.Normal)
        self.btRanking.setTitle("profile_ranking".localized, forState: UIControlState.Normal)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableviewMyStories {
            let story = storyList[indexPath.row]
            
            if story.cover != nil && story.cover.url != nil {
                return 471
            }else {
                return 471 - imgViewHistoryHeight
            }
        }else if tableView == self.tableviewAnsweredPoll {
            return UITableViewAutomaticDimension
        }else {
            return 65
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableviewMyStories {
            return storyList.count
        }else if tableView == self.tableviewAnsweredPoll {
            return pollList.count
        }else {
            return userList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.tableviewMyStories {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URStoriesTableViewCell.self), forIndexPath: indexPath) as! URStoriesTableViewCell
            cell.viewController = self
            cell.setupCellWith(storyList[indexPath.row],moderateUserMode: false)
            return cell
        }else if tableView == self.tableviewAnsweredPoll{
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URClosedPollTableViewCell.self), forIndexPath: indexPath) as! URClosedPollTableViewCell
            cell.setupCellWithData(pollList[indexPath.row])
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URRankingTableViewCell.self), forIndexPath: indexPath) as! URRankingTableViewCell
            cell.setupCellWith(userList[indexPath.row])
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell is URStoriesTableViewCell {
            self.navigationController?.pushViewController(URStoryContributionViewController(story: (cell as! URStoriesTableViewCell).story), animated: true)
        }else if cell is URClosedPollTableViewCell {
            self.navigationController?.pushViewController(URPollResultTableViewController(poll: (cell as! URClosedPollTableViewCell).poll), animated: true)
        }else {
                        
            let modalProfileViewController = URModalProfileViewController(user: (cell as! URRankingTableViewCell).user)
            modalProfileViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            
            dispatch_async(dispatch_get_main_queue(), {
                URNavigationManager.navigation.presentViewController(modalProfileViewController, animated: true) { () -> Void in
                    UIView.animateWithDuration(0.3) { () -> Void in
                        modalProfileViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
                    }
                }
            });
        }
    }
    
    
    //MARK: Button Events
    
    @IBAction func btMyStoriesTapped(sender: AnyObject) {
        if isBtMyStoriesTapped == false {
            isBtMyStoriesTapped = true
            self.tableviewMyStories.hidden = false
            self.tableviewAnsweredPoll.hidden = true
            self.tableviewRanking.hidden = true
            btMyStories.backgroundColor = URConstant.Color.DARK_BLUE
            btAnsweredPolls.backgroundColor = URConstant.Color.PRIMARY
            btRanking.backgroundColor = URConstant.Color.PRIMARY
            isBtAnsweredPollsTapped = false
            isBtRankingTapped = false
        }
    }

    @IBAction func btAnsweredPollsTapped(sender: AnyObject) {
        if isBtAnsweredPollsTapped == false {
            isBtAnsweredPollsTapped = true
            self.tableviewMyStories.hidden = true
            self.tableviewAnsweredPoll.hidden = false
            self.tableviewRanking.hidden = true
            btMyStories.backgroundColor = URConstant.Color.PRIMARY
            btAnsweredPolls.backgroundColor = URConstant.Color.DARK_BLUE
            btRanking.backgroundColor = URConstant.Color.PRIMARY
            isBtMyStoriesTapped = false
            isBtRankingTapped = false
        }
    }
    
    @IBAction func btRankingTapped(sender: AnyObject) {
        if isBtRankingTapped == false {
            isBtRankingTapped = true
            self.tableviewMyStories.hidden = true
            self.tableviewAnsweredPoll.hidden = true
            self.tableviewRanking.hidden = false
            btMyStories.backgroundColor = URConstant.Color.PRIMARY
            btAnsweredPolls.backgroundColor = URConstant.Color.PRIMARY
            btRanking.backgroundColor = URConstant.Color.DARK_BLUE
            isBtMyStoriesTapped = false
            isBtAnsweredPollsTapped = false
        }
    }
    
    @IBAction func btEditTapped(sender: AnyObject) {
        
        if URUser.activeUser()!.type != URType.UReport {
            URNavigationManager.navigation.pushViewController(URUserRegisterViewController(color: URConstant.Color.PRIMARY, user: URUser.activeUser()!,updateMode:true), animated: true)
        }else {
            
            let alertController = UIAlertController(title: nil, message: "title_media_source".localized, preferredStyle: .ActionSheet)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "cancel_dialog_button".localized, style: .Cancel) { action -> Void in
                
            }
            
            let passwordUpdateAction: UIAlertAction = UIAlertAction(title: "title_pref_change_password".localized, style: .Default) { action -> Void in
                self.navigationController?.pushViewController(URPasswordEditViewController(nibName:"URPasswordEditViewController", bundle:nil), animated: true)
            }
            
            let profileUpdateAction: UIAlertAction = UIAlertAction(title: "title_pref_edit_profile".localized, style: .Default) { action -> Void in
                URNavigationManager.navigation.pushViewController(URUserRegisterViewController(color: URConstant.Color.PRIMARY, user: URUser.activeUser()!,updateMode:true), animated: true)
            }
            
            alertController.addAction(passwordUpdateAction)
            alertController.addAction(profileUpdateAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btLogoutTapped(sender: AnyObject) {
        URNavigationManager.toggleMenu()
        URUser.deactivateUser()
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    }
    
}
