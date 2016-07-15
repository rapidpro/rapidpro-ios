//
//  URMainChatViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMainChatViewController: UITabBarController, UITabBarControllerDelegate {

    var appDelegate:AppDelegate!
    let myChatsTableViewController = URChatTableViewController(createGroupOption: false,myChatsMode:true)
    let groupsTableViewController = URGroupsTableViewController()
    let inviteTableViewController = URInviteTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.delegate = self
        
        setupViewControllers()
        addRightBarButtons()
        reloadUserInfo()
        
        self.title = "chat_title".localized
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationItem.leftBarButtonItem == nil {
            URNavigationManager.addLeftButtonMenuInViewController(self)
            self.view.userInteractionEnabled = true
            self.view.addGestureRecognizer(self.appDelegate.revealController!.panGestureRecognizer())
        }
        
        tabBarController(self, didSelectViewController: myChatsTableViewController)
        self.selectedViewController = myChatsTableViewController
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: Class Methods
    
    func reloadUserInfo() {
        
    }
    
    func setupViewControllers() {
        
        myChatsTableViewController.title = "My Chats".localized
        myChatsTableViewController.tabBarItem.image = UIImage(named: "icon_chat")
        
        groupsTableViewController.title = "Open Grops".localized
        groupsTableViewController.tabBarItem.image = UIImage(named: "icon_open_groups")
        
        inviteTableViewController.title = "Invite".localized
        inviteTableViewController.tabBarItem.image = UIImage(named: "icon_invite")
        
        self.viewControllers = [groupsTableViewController,myChatsTableViewController,inviteTableViewController]
    }
    
    func addRightBarButtons() -> UIBarButtonItem{
        self.navigationItem.rightBarButtonItem = nil
        let btnLogout: UIButton = UIButton(type: UIButtonType.Custom)
        btnLogout.frame = CGRectMake(0, 0, 23, 23)
        btnLogout.setBackgroundImage(UIImage(named:"iconNewMessage"), forState: UIControlState.Normal)
        btnLogout.addTarget(self, action: #selector(createChatRoom), forControlEvents: UIControlEvents.TouchUpInside)
        let container: UIView = UIView(frame: CGRectMake(0, 0, 23, 23))
        container.addSubview(btnLogout)
        let chatButtonItem = UIBarButtonItem(customView: container)
        return chatButtonItem
    }
    
    //MARK: SelectorMethods
    
    func createChatRoom() {
        self.navigationController?.pushViewController(URChatTableViewController(createGroupOption: true,myChatsMode:false), animated: true)
    }
    
    //MARK: TabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationItem.rightBarButtonItem = addRightBarButtons()
    }

}
