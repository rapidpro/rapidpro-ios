//
//  URProfileViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 25/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import IlhasoftCore
import MBProgressHUD

enum TabType {
    case myStories
    case answeredPolls
    case ranking
}

class URProfileViewController: UIViewController, URStoryManagerDelegate, URUserManagerDelegate, ISImageViewPickerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var roundedView: ISRoundedView!
    @IBOutlet weak var imageProfile: ISImageViewPicker!
    @IBOutlet weak var lbProfileDetails: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btEdit: UIButton!
    @IBOutlet weak var btLogout: UIButton!
    
    @IBOutlet weak var tableviewMyStories: UITableView!
    @IBOutlet weak var tableviewRanking: UITableView!
    
    @IBOutlet weak var btMyStories: UIButton!
    @IBOutlet weak var btRanking: UIButton!
    
    var tabType:TabType!
    
    var isBtMyStoriesTapped = false
    var isBtRankingTapped = false
    
    let imgViewHistoryHeight:CGFloat = 188.0
    let fullHeightTableViewCell:CGFloat = 497
    
    var storyList:[URStory] = []
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
        reloadStories()
        
        selectTabType(self.tabType)
        
        self.imageProfile.delegate = self
        self.imageProfile.parentViewController = self
        self.imageProfile.mediaSources = [.Gallery, .Camera]
        self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        URNavigationManager.setupNavigationBarWithType(.clear)
        setupDelegates()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Profile")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if imageProfile.image == nil {
            let user = URUser.activeUser()
            user!.picture = nil
            URUserManager.save(user!)
        }
    }
    
    //MARK: ISImageViewPickerDelegate
    
    public func mediaDidLoad(imageView: ISImageViewPicker, media: ISMedia) {
        if let imageMedia = media as? ISImageMedia {
            URAWSManager.uploadImage(imageMedia.image, uploadPath: .User, completion: {
                (picture:URMedia?) -> Void in
                
                if let media = picture {
                    let user = URUser.activeUser()
                    user!.picture = media.url
                    URUserManager.save(user!)
                }
            })
        }
    }
    
    public func mediaDidRemove(imageView: ISImageViewPicker, media: ISMedia) {
        
    }
    
    //MARK: StoryManagerDelegate
    @objc fileprivate func reloadStories() {
        storyManager.getStoriesWithCompletion(false, initQueryFromItem: storyList.count) { (storyList) in
            self.tableviewMyStories.setRefreshControlTo(animate: false)
            self.storyList = storyList.reversed()
            self.tableviewMyStories.reloadData()
        }
    }
    
    func newStoryReceived(_ story: URStory) {
        if story.user == URUser.activeUser()?.key {
            storyList.insert(story, at: 0)
            userList = userList.sorted{(($0.points?.int32Value)! > ($1.points?.int32Value)!)}
            self.tableviewMyStories.reloadData()
        }
    }
    
    //MARK: UserManagerDelegate
    
    func newUserReceived(_ user: URUser) {
        if (user.points != nil) {
            userList.insert(user, at: 0)
            self.tableviewRanking.reloadData()
        }
    }
    
    //MARK: Class Methods
    
    func selectTabType(_ type:TabType) {
        switch type {
        case .myStories:
            btMyStoriesTapped(self.btMyStories)
            break
        case .ranking:
            btRankingTapped(self.btRanking)
            break
        default:
            break
        }
    }
    
    func setupDelegates() {
        storyList = []
        userList = []
        pollManager.getPolls()
        storyManager.getStories(false,initQueryFromItem: storyList.count)
        storyManager.delegate = self
        userManager.delegate = self
        userManager.getUsersByPoints()
    }
    
    func setupTableView() {
        self.tableviewMyStories.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableviewMyStories.register(UINib(nibName: "URStoriesTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URStoriesTableViewCell.self))
        self.tableviewMyStories.separatorColor = UIColor.clear
        
        self.tableviewRanking.backgroundColor = UIColor.clear
        self.tableviewRanking.register(UINib(nibName: "URRankingTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URRankingTableViewCell.self))
        self.tableviewRanking.separatorColor = UIColor.clear
        self.tableviewMyStories.addRefreshControl(target: self, selector: #selector(reloadStories))
        
    }
    
    func loadUserInfo() {
        
        URUserManager.reloadUserInfoWithCompletion { (finish) in }
        
        if let user = URUser.activeUser() {
            if let picture = user.picture {
                self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(1)
                self.imageProfile.contentMode = UIViewContentMode.scaleAspectFill
                self.imageProfile.sd_setImage(with: URL(string: picture))
            }else{
                self.roundedView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                self.imageProfile.contentMode = UIViewContentMode.center
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
        
        #if ONTHEMOVE
                self.containerView.backgroundColor = URConstant.Color.PRIMARY
        #endif
        self.btEdit.layer.cornerRadius = 4
        self.btLogout.layer.cornerRadius = 4
        self.roundedView.layer.borderWidth = 2
        self.roundedView.layer.borderColor = UIColor.white.cgColor
        self.tableviewRanking.layer.cornerRadius = 5
        
        self.btEdit.setTitle("label_edit".localized, for: UIControlState())
        self.btMyStories.setTitle("label_view_stories".localized, for: UIControlState())
        self.btRanking.setTitle("profile_ranking".localized, for: UIControlState())
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableviewMyStories {
            let story = storyList[(indexPath as NSIndexPath).row]
            
            if story.cover != nil && story.cover?.url != nil {
                return fullHeightTableViewCell
            }else {
                return fullHeightTableViewCell - imgViewHistoryHeight
            }
        }else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableviewMyStories {
            return storyList.count
        }else {
            return userList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableviewMyStories {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URStoriesTableViewCell.self), for: indexPath) as! URStoriesTableViewCell
            cell.viewController = self
            cell.setupCellWith(storyList[(indexPath as NSIndexPath).row],moderateUserMode: false)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URRankingTableViewCell.self), for: indexPath) as! URRankingTableViewCell
            cell.setupCellWith(userList[indexPath.row])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell is URStoriesTableViewCell {
            self.navigationController?.pushViewController(URStoryContributionViewController(story: (cell as! URStoriesTableViewCell).story), animated: true)
        }else if cell is URClosedPollTableViewCell {
            self.navigationController?.pushViewController(URPollResultViewController(poll: (cell as! URClosedPollTableViewCell).poll), animated: true)
        }else {
            
            let modalProfileViewController = URModalProfileViewController(user: (cell as! URRankingTableViewCell).user)
            modalProfileViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            
            DispatchQueue.main.async(execute: {
                URNavigationManager.navigation.present(modalProfileViewController, animated: true) { () -> Void in
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        modalProfileViewController.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
                    }) 
                }
            });
        }
    }
    
    
    //MARK: Button Events
    
    @IBAction func btMyStoriesTapped(_ sender: AnyObject) {
        if isBtMyStoriesTapped == false {
            isBtMyStoriesTapped = true
            self.tableviewMyStories.isHidden = false
            self.tableviewRanking.isHidden = true
            btMyStories.backgroundColor = URConstant.Color.DARK_BLUE
            btRanking.backgroundColor = URConstant.Color.PRIMARY
            isBtRankingTapped = false
        }
    }
    
    @IBAction func btRankingTapped(_ sender: AnyObject) {
        if isBtRankingTapped == false {
            isBtRankingTapped = true
            self.tableviewMyStories.isHidden = true
            self.tableviewRanking.isHidden = false
            btMyStories.backgroundColor = URConstant.Color.PRIMARY
            btRanking.backgroundColor = URConstant.Color.DARK_BLUE
            isBtMyStoriesTapped = false
        }
    }
    
    @IBAction func btEditTapped(_ sender: AnyObject) {
        
        if URUser.activeUser()!.type != URType.UReport {
            URNavigationManager.navigation.pushViewController(URUserRegisterViewController(color: URConstant.Color.PRIMARY, user: URUser.activeUser()!,updateMode:true), animated: true)
        }else {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "cancel_dialog_button".localized, style: .cancel) { action -> Void in
                
            }
            
            let passwordUpdateAction: UIAlertAction = UIAlertAction(title: "title_pref_change_password".localized, style: .default) { action -> Void in
                self.navigationController?.pushViewController(URPasswordEditViewController(), animated: true)
            }
            
            let profileUpdateAction: UIAlertAction = UIAlertAction(title: "title_pref_edit_profile".localized, style: .default) { action -> Void in
                URNavigationManager.navigation.pushViewController(URUserRegisterViewController(color: URConstant.Color.PRIMARY, user: URUser.activeUser()!,updateMode:true), animated: true)
            }
            
            alertController.addAction(passwordUpdateAction)
            alertController.addAction(profileUpdateAction)
            alertController.addAction(cancelAction)
            
            if URConstant.isIpad {
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                alertController.popoverPresentationController!.sourceView = self.btEdit
                alertController.popoverPresentationController!.sourceRect = self.btEdit.bounds
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btLogoutTapped(_ sender: AnyObject) {
        URNavigationManager.toggleMenu()
        URUser.deactivateUser()
        URNavigationManager.setupNavigationControllerWithLoginViewController()
    }
    
}
