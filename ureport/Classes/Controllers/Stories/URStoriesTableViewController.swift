//
//  URStoriesTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import MBProgressHUD

class URStoriesTableViewController: UITableViewController, URStoryManagerDelegate, URStoriesTableViewCellDelegate, URWriteStoryViewDelegate {
    
    let imgViewHistoryHeight:CGFloat = 188.0
    let fullHeightTableViewCell:CGFloat = 497
    let contentViewBottom = 2
    let storyManager = URStoryManager()
    var storyList:[URStory] = []
    var newsList:[URNews] = []
    var filterStoriesToModerate:Bool!
    var modalProfileViewController:URModalProfileViewController!
    var index = 1
    var lastQueryItemIndex = 0
    
    init (filterStoriesToModerate:Bool) {
        self.storyList.removeAll()
        self.filterStoriesToModerate = filterStoriesToModerate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        if filterStoriesToModerate == false {
            loadNews()
        }else{
            self.reloadDataWithStories()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Stories")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    //MARK: URWriteStoryTableViewCellDelegate
    
    func writeStoryDidTap(cell: URWriteStoryView) {
        if URUser.activeUser() != nil {
            
            if URUserManager.userHasPermissionToAccessTheFeature(false) == true {
                self.navigationController?.pushViewController(URAddStoryViewController(), animated: true)
            }else {
                let alertController = UIAlertController(title: nil, message: "feature_without_permission".localized, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: {})
            }
            
        }else{
            URLoginAlertController.show(self)
        }
    }
    
    //MARK: URStoriesTableViewCellDelegate
    
    func openProfile(user: URUser) {
        self.modalProfileViewController = URModalProfileViewController(user: user)
        self.modalProfileViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.navigationController!.presentViewController(modalProfileViewController, animated: true) { () -> Void in
            UIView.animateWithDuration(0.3) { () -> Void in
                self.modalProfileViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
            }
        }
    }
    
    //MARK: MenuDelegateMethods
    
    func countryProgramDidChanged(countryProgram: URCountryProgram) {
        storyList.removeAll()
        storyManager.getStoriesWithCompletion(filterStoriesToModerate, initQueryFromItem: storyList.count) { (storyList) in
            self.storyList = storyList.reverse()
            self.tableView.reloadData()
            self.storyManager.getStories(self.filterStoriesToModerate, initQueryFromItem: storyList.count)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (filterStoriesToModerate == false){
            return 58
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader =  NSBundle.mainBundle().loadNibNamed("URWriteStoryView", owner: 0, options: nil)[0] as! URWriteStoryView
        viewHeader.delegate = self
        
        if (filterStoriesToModerate == false){
            self.tableView.tableHeaderView = viewHeader
            sizeHeaderToFit()
        }else{
            viewHeader.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        return viewHeader
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storyList.count + self.newsList.count
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row < self.storyList.count {
            let story = storyList[indexPath.row]
            
            if story.cover != nil && story.cover.url != nil {
                return fullHeightTableViewCell
            }else {
                return fullHeightTableViewCell - imgViewHistoryHeight
            }
        }else {
            return 245
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == storyList.count - 1 && storyList.count >= storyManager.itensByQuery {
            storyManager.getStoriesWithCompletion(filterStoriesToModerate, initQueryFromItem: storyList.count) { (storyList) in
                self.storyList = storyList.reverse()
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row < self.storyList.count {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URStoriesTableViewCell.self), forIndexPath: indexPath) as! URStoriesTableViewCell
            
            let story = storyList[indexPath.row]
            cell.delegate = self
            cell.viewController = self
            cell.setupCellWith(story,moderateUserMode: self.filterStoriesToModerate)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URNewsTableViewCell.self), forIndexPath: indexPath) as! URNewsTableViewCell
            let news = newsList[indexPath.row - self.storyList.count]
            cell.setupCellWith(news)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell is URStoriesTableViewCell {
            if let _ = URUser.activeUser() {
                self.navigationController?.pushViewController(URStoryContributionViewController(story: (cell as! URStoriesTableViewCell).story), animated: true)
            }else {
                URLoginAlertController.show(self)
            }
        }else if cell is URNewsTableViewCell {
            self.navigationController?.pushViewController(URNewsDetailViewController(news:(cell as! URNewsTableViewCell).news),animated: true)
        }
    }
    
    //MARK: Class Methods
    
    func sizeHeaderToFit() {
        let headerView = self.tableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        self.tableView.tableHeaderView = headerView
    }
    
    func loadNews() {
        
        if let org = URCountryProgramManager.activeCountryProgram()!.org {
            let url = "\(URCountryProgramManager.activeCountryProgram()!.ureportHostAPI)\(org)"
            Alamofire.request(.GET, url, headers: nil).responseObject({ (response:URAPIResponse<URNews>?, error:ErrorType?) -> Void in
                if let response = response {
                    self.newsList = response.results
                    self.tableView.reloadData()
                    self.reloadDataWithStories()
                }
            })
            
        }
        
    }
    
    func reloadDataWithStories() {
        storyManager.delegate = self
        
        storyList.removeAll()
        self.storyManager.getStories(self.filterStoriesToModerate, initQueryFromItem: self.storyList.count)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        storyManager.getStoriesWithCompletion(filterStoriesToModerate, initQueryFromItem: storyList.count) { (storyList) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.storyList = storyList.reverse()
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
        
        self.tableView.registerNib(UINib(nibName: "URStoriesTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URStoriesTableViewCell.self))
        self.tableView.registerNib(UINib(nibName: "URNewsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URNewsTableViewCell.self))
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    //MARK: StoryManagerDelegate
    
    func removeCell(cell: URStoriesTableViewCell) {
        let indexPath = self.tableView.indexPathForCell(cell)!
        self.storyList.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func newStoryReceived(story: URStory) {
        let hasStory = self.storyList.indexOf{($0.key == story.key)}
        
        if hasStory == nil {
            storyList.insert(story, atIndex: 0)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: storyList.count - index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            index += 1
        }
    }
    
}
