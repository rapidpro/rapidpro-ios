//
//  URStoryContributionViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 16/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import youtube_ios_player_helper
import SDWebImage
import MediaPlayer

class URStoryContributionViewController: UIViewController, URContributionManagerDelegate, URContributionTableViewCellDelegate, URAddContributionTableViewCellDelegate {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMarkers: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewMedias: ISScrollViewPage!
    @IBOutlet weak var lbContributions: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgProfile: UIImageView?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var roundedView: UIView?
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btLike: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewMediaHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNoContributions: UILabel?
    @IBOutlet weak var viewNoContribution: ISRoundedView?
    @IBOutlet weak var txtContribute: UITextField?
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    let contributionManager = URContributionManager()
    
    var listContribution:[URContribution] = []
    var story:URStory!
    var photos:[PhotoShow] = []
    
    init(story:URStory) {
        if URConstant.isIpad {
            super.init(nibName: "URStoryContributionViewIPadController", bundle: nil)
        }else {
            super.init(nibName: "URStoryContributionViewController", bundle: nil)
        }
        self.story = story
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStory()
        setupTableView()
        setupScrollView()
        setupScrollViewMedias()
        self.title = story.userObject!.nickname
        contributionManager.getContributions(story.key)
        contributionManager.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        URNavigationManager.setupNavigationBarWithType(URConstant.isIpad ? .Blue : .Clear)
        
        if !URConstant.isIpad {
            self.navigationController?.hidesBarsOnSwipe = true
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Story Detail")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.lbContent.setSizeFont(14)
        
        if !URConstant.isIpad {
            if story.medias == nil {
                self.scrollViewMediaHeight.constant = 0
            }
            
            let scrollViewHeight = self.tableView.contentSize.height + self.tableView.frame.origin.y
            
            self.tableViewHeight.constant = self.tableView.contentSize.height
            self.scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width,scrollViewHeight)
            self.contentViewHeight.constant = self.scrollView.contentSize.height
            
        }
    }
    
    //MARK: Class Methods
    
    func setupStory() {
        
        self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [0])
        self.lbTitle.text = story.title
        self.lbMarkers.text = story.markers
        self.lbContent.text = story.content
        
        if story.userObject != nil && story.userObject!.picture == nil{
            self.imgProfile?.contentMode = UIViewContentMode.Center
            self.imgProfile?.image = UIImage(named: "ic_person")
            
            self.roundedView?.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        }else if let userObject = story.userObject {
            self.imgProfile?.sd_setImageWithURL(NSURL(string: userObject.picture))
        }
        
        if story.like == nil {
            story.like = 0
        }

        self.btLike.setTitle(String(format: "likes".localized, arguments: [story.like != nil ? Int(story.like) : 0]), forState: UIControlState.Normal)
        
        URStoryManager.checkIfStoryWasLiked(story.key) { (liked) -> Void in
             self.btLike.enabled = true
             self.setupLikeButtonAsLiked(liked)
        }
        
    }
    
    func incrementLikeButton() {
        let likeCount = Int(story.like) + 1
        story.like = likeCount
        self.btLike.setTitle(String(format: "likes".localized, arguments: [likeCount]), forState: UIControlState.Normal)
    }
    
    func decrementLikeButton() {
        let likeCount = Int(story.like) - 1
        story.like = likeCount
        self.btLike.setTitle(String(format: "likes".localized, arguments: [likeCount]), forState: UIControlState.Normal)
    }
    
    func setupTableView() {
        
        if URConstant.isIpad {
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URContributionTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URContributionTableViewCell.self))
        self.tableView.registerNib(UINib(nibName: "URAddContributionTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URAddContributionTableViewCell.self))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 68.0
    }

    // MARK: - Table view data source
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return URConstant.isIpad ? 0 : 50
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if URConstant.isIpad {
            return nil
        }
        
        let viewFooter =  NSBundle.mainBundle().loadNibNamed("URAddContributionTableViewCell", owner: 0, options: nil)[0] as! URAddContributionTableViewCell
        viewFooter.delegate = self
        viewFooter.parentViewController = self
//        self.tableView.tableFooterView = viewFooter
        
        return viewFooter
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listContribution.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URContributionTableViewCell.self), forIndexPath: indexPath) as! URContributionTableViewCell
        
        cell.setupCellWith(self.listContribution[indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
    }
    
    //MARK: URContributionTableViewCellDelegate
    
    func newContributionAdded(cell: URAddContributionTableViewCell) {
        sendContribution(cell.txtContribution)
    }
    
    //MARK: Button Events
    
    
    @IBAction func btSendTapped(button:UIButton) {
        sendContribution(self.txtContribute!)
    }
    
    @IBAction func btLikeTapped(button:UIButton) {
        if button.selected == true {
            URStoryManager.removeStoryLike(self.story.key)
            setupLikeButtonAsLiked(false)
            decrementLikeButton()
        }else{
            URStoryManager.saveStoryLike(self.story.key)
            setupLikeButtonAsLiked(true)
            incrementLikeButton()
        }
    }
    
    //MARK: Class Methods
    
    func sizeHeaderToFit() {
        let headerView = self.tableView.tableFooterView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        self.tableView.tableFooterView = headerView
    }
    
    func sendContribution(textField:UITextField) {
        if !textField.text!.isEmpty {
            
            if URUserManager.userHasPermissionToAccessTheFeature(false) {
                
                let user = URUser()
                user.key = URUser.activeUser()!.key
                
                let contribution = URContribution()
                contribution.content = textField.text!
                contribution.author = user
                contribution.createdDate = NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000))
                
                URContributionManager.saveContribution(story.key, contribution: contribution, completion: { (success) -> Void in
                    URUserManager.incrementUserContributions(user.key)
                    textField.text = ""
                    textField.resignFirstResponder()
                    let bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)

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
    
    func setupLikeButtonAsLiked(liked:Bool) {
        if liked == true {
            self.btLike.selected = true
            self.btLike.setImage(UIImage(named: "likeBigPressed"), forState: UIControlState.Selected)
        }else{
            self.btLike.selected = false
            self.btLike.setImage(UIImage(named: "likeBig"), forState: UIControlState.Normal)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupScrollViewMedias() {
        
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.ISScrollViewPageHorizontally
        
        if story.medias != nil && story.medias.count > 0 {
            
            for media in story.medias {                
                let playMediaView = URPlayMediaView(parentViewController: self, media: media)
                self.scrollViewMedias.addCustomView(playMediaView)
            }
                
        }
    }
    
    
    func setupScrollView() {
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }
    
    //MARK: URStoryContributionTableViewCellDelegate
    
    func contributionTableViewCellDeleteButtonTapped(cell: URContributionTableViewCell) {
        
        let alert = UIAlertController(title: nil, message: "message_remove_chat_message".localized, preferredStyle: UIAlertControllerStyle.ActionSheet)

        alert.addAction(UIAlertAction(title: "label_remove".localized, style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            let indexPath = self.tableView.indexPathForCell(cell)!
            self.listContribution.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            let totalContributions = Int(self.story.contributions) - 1
            self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [totalContributions])
            
            self.tableView.contentSize.height = CGFloat(totalContributions)
            URContributionManager.removeContribution(self.story.key, contributionKey: cell.contribution.key)
            
            self.view.layoutIfNeeded()
            
        }))
        
        if URConstant.isIpad {
            alert.modalPresentationStyle = UIModalPresentationStyle.Popover
            alert.popoverPresentationController!.sourceView = cell.btDelete
            alert.popoverPresentationController!.sourceRect = cell.btDelete.bounds
        }

        alert.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: UIAlertActionStyle.Cancel, handler:nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //MARK: ContributionManagerDelegate
    
    func newContributionReceived(contribution: URContribution) {
        self.viewNoContribution?.hidden = true
        self.lbNoContributions?.hidden = true
        listContribution.append(contribution)
        self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [listContribution.count])
        tableView.reloadData()
    }
    
    
    //MARK: TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendContribution(textField)
        return true
    }

    override func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let _ = URUser.activeUser() {
            return true
        }else {
            URLoginAlertController.show(self)
            return false
        }
    }

}
