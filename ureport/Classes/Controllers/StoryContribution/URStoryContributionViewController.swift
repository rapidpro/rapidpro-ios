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
import ISScrollViewPageSwift

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
        
        if !URConstant.isIpad {
            setupFooterView()
        }
        
        self.title = story.userObject!.nickname
        contributionManager.getContributions(story.key)
        contributionManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        URNavigationManager.setupNavigationBarWithType(URConstant.isIpad ? .blue : .clear)
        
        if !URConstant.isIpad {
            self.navigationController?.hidesBarsOnSwipe = true
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Story Detail")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width,height: scrollViewHeight)
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
            self.imgProfile?.contentMode = UIViewContentMode.center
            self.imgProfile?.image = UIImage(named: "ic_person")
            
            self.roundedView?.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        }else if let userObject = story.userObject {
            self.imgProfile?.sd_setImage(with: URL(string: userObject.picture!))
        }
        
        if story.like == nil {
            story.like = 0
        }

        self.btLike.setTitle(String(format: "likes".localized, arguments: [story.like != nil ? Int(story.like!) : 0]), for: UIControlState())
        
        URStoryManager.checkIfStoryWasLiked(story.key!) { (liked) -> Void in
             self.btLike.isEnabled = true
             self.setupLikeButtonAsLiked(liked)
        }
        
    }
    
    func incrementLikeButton() {
        let likeCount = Int(story.like!) + 1
        story.like = likeCount as NSNumber!
        self.btLike.setTitle(String(format: "likes".localized, arguments: [likeCount]), for: UIControlState())
    }
    
    func decrementLikeButton() {
        let likeCount = Int(story.like!) - 1
        story.like = likeCount as NSNumber!
        self.btLike.setTitle(String(format: "likes".localized, arguments: [likeCount]), for: UIControlState())
    }
    
    func setupTableView() {
        
        if URConstant.isIpad {
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "URContributionTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URContributionTableViewCell.self))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 68.0
        
//        if !URConstant.isIpad {
//            let viewFooter =  Bundle.main.loadNibNamed("URAddContributionTableViewCell", owner: 0, options: nil)?[0] as! URAddContributionTableViewCell
//            viewFooter.delegate = self
//            viewFooter.parentViewController = self
//            self.tableView.tableFooterView = viewFooter
//        }
        
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listContribution.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URContributionTableViewCell.self), for: indexPath) as! URContributionTableViewCell
        
        cell.setupCellWith(self.listContribution[(indexPath as NSIndexPath).row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
    //MARK: URContributionTableViewCellDelegate
    
    func newContributionAdded(_ cell: URAddContributionTableViewCell) {
        sendContribution(cell.txtContribution)
    }
    
    //MARK: Button Events
    
    
    @IBAction func btSendTapped(_ button:UIButton) {
        sendContribution(self.txtContribute!)
    }
    
    @IBAction func btLikeTapped(_ button:UIButton) {
        if button.isSelected == true {
            URStoryManager.removeStoryLike(self.story.key!)
            setupLikeButtonAsLiked(false)
            decrementLikeButton()
        }else{
            URStoryManager.saveStoryLike(self.story.key!)
            setupLikeButtonAsLiked(true)
            incrementLikeButton()
        }
    }
    
    //MARK: Class Methods
    
    func setupFooterView() {
        let viewFooter =  Bundle.main.loadNibNamed("URAddContributionTableViewCell", owner: 0, options: nil)?[0] as! URAddContributionTableViewCell
        viewFooter.delegate = self
        viewFooter.txtContribution.delegate = self
        viewFooter.parentViewController = self
        self.tableView.tableFooterView = viewFooter.contentView
    }
    
    func sendContribution(_ textField:UITextField) {
        if !textField.text!.isEmpty {
            
            if URUserManager.userHasPermissionToAccessTheFeature(false) {
                
                let user = URUser()
                user.key = URUser.activeUser()!.key
                
                let contribution = URContribution()
                contribution.content = textField.text!
                contribution.author = user
                contribution.createdDate = NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64)
                
                URContributionManager.saveContribution(story.key!, contribution: contribution, completion: { (success) -> Void in
                    URUserManager.incrementUserContributions(user.key)
                    textField.text = ""
                    self.view.endEditing(true)
                    //textField.resignFirstResponder()
                    //let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                    //self.scrollView.setContentOffset(bottomOffset, animated: true)

                })
                
            }else {
                if URUserManager.userHasPermissionToAccessTheFeature(false) == false {
                    let alertController = UIAlertController(title: nil, message: "feature_without_permission".localized, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: {})
                }
            }
            
        }
    }
    
    func setupLikeButtonAsLiked(_ liked:Bool) {
        if liked == true {
            self.btLike.isSelected = true
            self.btLike.setImage(UIImage(named: "likeBigPressed"), for: UIControlState.selected)
        }else{
            self.btLike.isSelected = false
            self.btLike.setImage(UIImage(named: "likeBig"), for: UIControlState())
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setupScrollViewMedias() {
        
        scrollViewMedias.setFillContent(false)
        scrollViewMedias.setEnableBounces(false)
        scrollViewMedias.setPaging(false)
        scrollViewMedias.scrollViewPageType = ISScrollViewPageType.isScrollViewPageHorizontally
        
        if story.medias != nil && (story.medias?.count)! > 0 {
            
            for media in story.medias! {                
                let playMediaView = URPlayMediaView(parentViewController: self, media: media)
                self.scrollViewMedias.addCustomView(playMediaView)
            }
                
        }
    }
    
    
    func setupScrollView() {
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }
    
    //MARK: URStoryContributionTableViewCellDelegate
    
    func contributionTableViewCellDeleteButtonTapped(_ cell: URContributionTableViewCell) {
        
        let alert = UIAlertController(title: nil, message: "message_remove_chat_message".localized, preferredStyle: UIAlertControllerStyle.actionSheet)

        alert.addAction(UIAlertAction(title: "label_remove".localized, style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            let indexPath = self.tableView.indexPath(for: cell)!
            self.listContribution.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            let totalContributions = Int(self.story.contributions) - 1
            self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [totalContributions])
            
            //self.tableView.contentSize.height = CGFloat(totalContributions)
            //URContributionManager.removeContribution(self.story.key!, contributionKey: cell.contribution.key!)
            
            //self.view.layoutIfNeeded()
            
        }))
        
        if URConstant.isIpad {
            alert.modalPresentationStyle = UIModalPresentationStyle.popover
            alert.popoverPresentationController!.sourceView = cell.btDelete
            alert.popoverPresentationController!.sourceRect = cell.btDelete.bounds
        }

        alert.addAction(UIAlertAction(title: "cancel_dialog_button".localized, style: UIAlertActionStyle.cancel, handler:nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: ContributionManagerDelegate
    
    func newContributionReceived(_ contribution: URContribution) {
        self.viewNoContribution?.isHidden = true
        self.lbNoContributions?.isHidden = true
        listContribution.append(contribution)
        self.lbContributions.text = String(format: "stories_list_item_contributions".localized, arguments: [listContribution.count])
        tableView.reloadData()
    }
    
    
    //MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendContribution(textField)
        return true
    }

    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let _ = URUser.activeUser() {
            return true
        }else {
            URLoginAlertController.show(self)
            return false
        }
    }

}
