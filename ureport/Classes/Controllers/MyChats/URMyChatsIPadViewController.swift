//
//  URMyChatsIPadViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 05/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URMyChatsIPadViewController: UISplitViewController, URMyChatsViewControllerDelegate, URChatTableViewControllerDelegate, URMessagesViewControllerDelegate {

    let myChatsViewController = URMyChatsViewController()
    var messagesViewController = URMessagesViewController(chatRoom: nil, chatMembers: [], title: nil)
    
    var popOverViewController:UIPopoverController?
    var chatRoomKeyToOpen:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .AllVisible
        self.extendedLayoutIncludesOpaqueBars = true
        
        myChatsViewController.delegate = self
        messagesViewController.delegate = self
        
        setupViewControllers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.translucent = false
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.tabBarController?.tabBar.translucent = false
    }
    
    //MARK: URMessagesViewControllerDelegate
    
    func mediaButtonDidTap() {
        self.view.addSubview(messagesViewController.mediaSourceViewController.view)
        messagesViewController.mediaSourceViewController.delegate = messagesViewController
        messagesViewController.mediaSourceViewController.toggleView { (finish) -> Void in}
    }
    
    //MARK: URChatTableViewControllerDelegate
    
    func openChatRoom(chatRoom: URChatRoom, chatMembers members: [URUser], title: String) {
        self.popOverViewController?.dismissPopoverAnimated(true)
        self.messagesViewController.chatRoom = chatRoom
        self.messagesViewController.chatMembers = members
        self.messagesViewController.navigationTitle = title
        self.messagesViewController.loadMessagesController()
        self.messagesViewController.updateReadMessages()
    }
    
    func openNewGroupViewController(newGroupViewController: URNewGroupViewController) {
        self.popOverViewController?.dismissPopoverAnimated(true)
        self.navigationController!.pushViewController(newGroupViewController, animated: true)
    }
    
    //MARK: URChatTableViewControllerDelegate
    
    func openChatRoomWith(chatRoom: URChatRoom, chatMembers: [URUser], title: String) {
        self.popOverViewController?.dismissPopoverAnimated(true)
        self.messagesViewController.chatRoom = chatRoom
        self.messagesViewController.chatMembers = chatMembers
        self.messagesViewController.navigationTitle = title
        self.messagesViewController.loadMessagesController()
        self.messagesViewController.updateReadMessages()
    }
    
    //MARK: SelectorMethods
    
    func createChatRoom(barButtonItem:UIBarButtonItem) {
        let chatTableViewController = URChatTableViewController(createGroupOption: true,myChatsMode:false)
        chatTableViewController.delegate = self
        
        chatTableViewController.view.backgroundColor = UIColor.whiteColor()
        popOverViewController = UIPopoverController(contentViewController: chatTableViewController)
        popOverViewController!.popoverContentSize = CGSize(width: 320, height: 500)
        
        presentPopOver(barButtonItem)
    }
    
    func invitePeople(barButtonItem:UIBarButtonItem) {
        let inviteTableViewController = URInviteTableViewController()
        inviteTableViewController.view.backgroundColor = UIColor.whiteColor()
        popOverViewController = UIPopoverController(contentViewController: inviteTableViewController)
        popOverViewController!.popoverContentSize = CGSize(width: 320, height: 500)
        
        presentPopOver(barButtonItem)
    }
    
    //MARK: Class Methods
    
    func presentPopOver(anyObject:AnyObject) {
        
        var objectView:UIView?
        
        if let view = anyObject as? UIBarButtonItem {
            objectView = view.valueForKey("view") as! UIView
        }else {
            return
        }
        
        popOverViewController!.presentPopoverFromRect(objectView!.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    
    func addRightBarButtons() -> [UIBarButtonItem]{
        
        self.navigationItem.rightBarButtonItem = nil
        
        let chatButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(createChatRoom(_:)))
        let inviteButtonItem = UIBarButtonItem(image: UIImage(named:"icon_invite_friend"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(invitePeople(_:)))
        
        return [chatButtonItem,inviteButtonItem]
    }
    
    func setupViewControllers() {
        
        myChatsViewController.navigationItem.rightBarButtonItems = addRightBarButtons()
        URNavigationManager.addLeftButtonMenuInViewController(myChatsViewController)
        
        myChatsViewController.title = "chat_rooms".localized
        
        let leftNavigationController = UINavigationController(rootViewController: myChatsViewController)
        setupNavigationDefaultAtrributes(leftNavigationController)
        
        let rightNavigationController = UINavigationController(rootViewController: messagesViewController)
        setupNavigationDefaultAtrributes(rightNavigationController)
        
        self.viewControllers = [leftNavigationController,rightNavigationController]
    }
    
    func setupNavigationDefaultAtrributes(navigationController:UINavigationController) {
        
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                                                              NSFontAttributeName:UIFont(name: "Avenir-Light", size: 20) as! AnyObject
        ]
        
        navigationController.navigationBar.barTintColor = URConstant.Color.PRIMARY
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.translucent = true
    }
    

}