//
//  URMainViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 13/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import Proposer

class URMainViewController: UITabBarController, UITabBarControllerDelegate, URClosedPollTableViewControllerDelegate, URMyChatsViewControllerDelegate {
    
    var appDelegate:AppDelegate!
    var chatRoomKey:String?
    
    let storiesTableViewController = URStoriesTableViewController(filterStoriesToModerate: false)
    let myChatsViewController = URConstant.isIpad ? URMyChatsIPadViewController() : URMyChatsViewController()
    let closedPollViewController = URConstant.isIpad ? URPollViewIPadController() : URClosedPollTableViewController()
    
    var viewControllerToShow:UIViewController?
    var visibleViewController:UIViewController?
    
    static let sharedInstance = URMainViewController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewControllerToShow:UIViewController?) {
        self.viewControllerToShow = viewControllerToShow
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
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appDelegate.requestPermissionForPushNotification(UIApplication.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBadgeMyChatsViewController), name:NSNotification.Name(rawValue: "newChatReceived"), object: nil)
        
        if let closedPollViewController = closedPollViewController as? URClosedPollTableViewController {
            closedPollViewController.delegate = self
        }
        
        if let myChatsViewController = myChatsViewController as? URMyChatsViewController {
            myChatsViewController.delegate = self
        }
        
        setupViewControllers()
        self.title = "U-Report"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        URUserManager.reloadUserInfoWithCompletion { (finish) in }
        
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Main")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
    }
    
    //MARK: URMyChatsViewControllerDelegate
    
    func openChatRoomWith(_ chatRoom: URChatRoom, chatMembers: [URUser], title: String) {
        self.navigationController?.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:chatMembers,title:title), animated: true)
    }
    
    //MARK: URClosedPollTableViewControllerDelegate
    
    func tableViewCellDidTap(_ cell: URClosedPollTableViewCell, isIPad:Bool) {
        if !isIPad {
            self.navigationController?.pushViewController(URPollResultViewController(poll: cell.poll), animated: true)
        }
    }
    
    //MARK: Class Methods
    
    func addBadgeMyChatsViewController() {
        visibleViewController = self.navigationController?.visibleViewController
        if !(visibleViewController is URMyChatsViewController || self.selectedViewController is URMyChatsViewController) {
            myChatsViewController.tabBarItem.badgeValue = "1"
        }
    }
    
    func setupViewControllers() {
        
        storiesTableViewController.title = "stories_moderation".localized
        storiesTableViewController.tabBarItem.image = UIImage(named: "icon_stories")
        
        closedPollViewController.title = "main_polls".localized
        closedPollViewController.tabBarItem.image = UIImage(named: "icon_polls")
        
        myChatsViewController.title = "chat_rooms".localized
        myChatsViewController.tabBarItem.image = UIImage(named: "icon_chats")
        
        if URUserManager.userHasPermissionToAccessTheFeature(false) == true {
            self.viewControllers = [storiesTableViewController,closedPollViewController,myChatsViewController]
            
            if chatRoomKey != nil {
                
                if let myChatsViewController = myChatsViewController as? URMyChatsViewController {
                    myChatsViewController.chatRoomKeyToOpen = chatRoomKey
                }else if let myChatsViewController = myChatsViewController as? URMyChatsIPadViewController {
                    myChatsViewController.chatRoomKeyToOpen = chatRoomKey
                }
                
                chatRoomKey = nil
                
                tabBarController(self, didSelect: myChatsViewController)
                self.selectedIndex = 2
            }else if let viewControllerToShow = self.viewControllerToShow {
                
                if viewControllerToShow is URClosedPollTableViewController {
                    self.selectedIndex = 1
                    tabBarController(self, didSelect: closedPollViewController)
                }else if viewControllerToShow is URStoriesTableViewController {
                    self.selectedIndex = 0
                    tabBarController(self, didSelect: storiesTableViewController)
                }
                
            }else{
                self.selectedIndex = 0
                tabBarController(self, didSelect: storiesTableViewController)
            }
        }else {
            self.viewControllers = [storiesTableViewController,closedPollViewController]
        }
        
    }
    
    func addRightBarButtons() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let chatButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createChatRoom))
        
        let btnInvite: UIButton = UIButton(type: UIButtonType.custom)
        btnInvite.frame = CGRect(x: 0, y: 5, width: 30, height: 20)
        btnInvite.setBackgroundImage(UIImage(named:"icon_invite_friend"), for: UIControlState())
        btnInvite.addTarget(self, action: #selector(invitePeople), for: UIControlEvents.touchUpInside)
        let container2: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        container2.addSubview(btnInvite)
        let inviteButtonItem = UIBarButtonItem(customView: container2)
        
        return [chatButtonItem,inviteButtonItem]
    }
    
    //MARK: SelectorMethods
    
    func createChatRoom() {
        URNavigationManager.navigation.pushViewController(URChatTableViewController(createGroupOption: true), animated: true)
    }
    
    func invitePeople() {
        
        proposeToAccess(PrivateResource.contacts, agreed: {
          
            URNavigationManager.navigation.pushViewController(URInviteTableViewController(), animated: true)            
            
            }, rejected: {
                self.alertNoPermissionToAccess(PrivateResource.contacts)
        })
    }
    
    func newStory() {
        if let _ = URUser.activeUser() {
            self.navigationController!.pushViewController(URAddStoryViewController(), animated: true)
        }else {
            URLoginAlertController.show(self)
        }
    }
    
    //MARK: TabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is URClosedPollTableViewController || viewController is URMyChatsViewController || viewController is URMyChatsIPadViewController {
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController is URStoriesTableViewController {
            self.title = "U-Report"            
            if URUserManager.userHasPermissionToAccessTheFeature(false) == true {
                self.navigationItem.rightBarButtonItems = nil
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newStory))
            }
        }
        
        if viewController is URClosedPollTableViewController || viewController is URPollViewIPadController {
            self.title = "main_polls".localized
            self.navigationItem.rightBarButtonItems = nil
        }
        
        if viewController is URMyChatsViewController || viewController is URMyChatsIPadViewController {
            self.title = "U-Report"
            viewController.tabBarItem.badgeValue = nil
            self.navigationItem.rightBarButtonItems = addRightBarButtons()
        }
        
    }
    
}
