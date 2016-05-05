//
//  URMainViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMainViewController: UITabBarController, UITabBarControllerDelegate, URClosedPollTableViewControllerDelegate {
    
    var appDelegate:AppDelegate!
    var chatRoomKey:String?
    
    let storiesTableViewController = URStoriesTableViewController(filterStoriesToModerate: false)
    let myChatsViewController = URMyChatsViewController()
    let closedPollViewController = URConstant.isIpad ? URPollViewIPadController() : URClosedPollTableViewController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(chatRoomKey:String?) {
        self.chatRoomKey = chatRoomKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.appDelegate.requestPermissionForPushNotification(UIApplication.sharedApplication())
        
        if let closedPollViewController = closedPollViewController as? URClosedPollTableViewController {
            closedPollViewController.delegate = self
        }
        
        tabBarController(self, didSelectViewController: storiesTableViewController)
        setupViewControllers()
        self.title = "U-Report"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadUserInfo()
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Main")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    //MARK: URClosedPollTableViewControllerDelegate
    
    func tableViewCellDidTap(cell: URClosedPollTableViewCell, isIPad:Bool) {
        if !isIPad {
            self.navigationController?.pushViewController(URPollResultTableViewController(poll: cell.poll), animated: true)
        }
    }
    
    //MARK: Class Methods    
    
    func reloadUserInfo() {
        if let user = URUser.activeUser() {
            URUserManager.getByKey(user.key, completion: { (userFromDB, exists) -> Void in
                if let userFromDB = userFromDB {
                    URUser.setActiveUser(userFromDB)
                    URUserLoginManager.setLoggedUser(userFromDB)
                }
            })
        }
    }
    
    func setupViewControllers() {
        
        storiesTableViewController.title = "stories_moderation".localized
        storiesTableViewController.tabBarItem.image = UIImage(named: "icon_stories.png")
        
        closedPollViewController.title = "poll_results".localized
        closedPollViewController.tabBarItem.image = UIImage(named: "icon_polls.png")
        
        myChatsViewController.title = "chat_rooms".localized
        myChatsViewController.tabBarItem.image = UIImage(named: "icon_chats.png")
        
        if URUserManager.userHasPermissionToAccessTheFeature(false) == true {
            self.viewControllers = [storiesTableViewController,closedPollViewController, myChatsViewController]
            
            if chatRoomKey != nil {
                myChatsViewController.chatRoomKeyToOpen = chatRoomKey
                tabBarController(self, didSelectViewController: myChatsViewController)
                self.selectedIndex = 2
            }
        }else {
            self.viewControllers = [storiesTableViewController,closedPollViewController]
        }
        
    }
    
    func addRightBarButtons() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        let btnCreateChat: UIButton = UIButton(type: UIButtonType.Custom)
        btnCreateChat.frame = CGRectMake(0, 0, 23, 23)
        btnCreateChat.setBackgroundImage(UIImage(named:"iconNewMessage"), forState: UIControlState.Normal)
        btnCreateChat.addTarget(self, action: #selector(createChatRoom), forControlEvents: UIControlEvents.TouchUpInside)
        let container: UIView = UIView(frame: CGRectMake(0, 0, 23, 23))
        container.addSubview(btnCreateChat)
        let chatButtonItem = UIBarButtonItem(customView: container)
        
        let btnInvite: UIButton = UIButton(type: UIButtonType.Custom)
        btnInvite.frame = CGRectMake(0, 0, 23, 23)
        btnInvite.setBackgroundImage(UIImage(named:"icon_invite_white"), forState: UIControlState.Normal)
        btnInvite.addTarget(self, action: #selector(invitePeople), forControlEvents: UIControlEvents.TouchUpInside)
        let container2: UIView = UIView(frame: CGRectMake(0, 0, 30, 23))
        container2.addSubview(btnInvite)
        let inviteButtonItem = UIBarButtonItem(customView: container2)
        
        return [chatButtonItem,inviteButtonItem]
    }
    
    //MARK: SelectorMethods
    
    func createChatRoom() {
        URNavigationManager.navigation.pushViewController(URChatTableViewController(createGroupOption: true,myChatsMode:false), animated: true)
    }
    
    func invitePeople() {
        URNavigationManager.navigation.pushViewController(URInviteTableViewController(), animated: true)
    }
    
    func newStory() {
        if let _ = URUser.activeUser() {
            self.navigationController!.pushViewController(URAddStoryViewController(), animated: true)
        }else {
            URLoginAlertController.show(self)
        }
    }
    
    //MARK: TabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if viewController is URClosedPollTableViewController || viewController is URMyChatsViewController {
            if let _ = URUser.activeUser() {
                return true
            }else {
                URLoginAlertController.show(self)                
                return false
            }
        }else {
            return true
        }
        
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        if viewController is URStoriesTableViewController {
            self.title = "U-Report"            
            if URUserManager.userHasPermissionToAccessTheFeature(false) == true {
                self.navigationItem.rightBarButtonItems = nil
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(newStory))
            }
        }
        
        if viewController is URClosedPollTableViewController{
            self.title = "poll_results".localized
            self.navigationItem.rightBarButtonItems = nil
        }
        
        if viewController is URMyChatsViewController {
            self.title = "U-Report"
            self.navigationItem.rightBarButtonItems = addRightBarButtons()
        }
        
    }
    
}
