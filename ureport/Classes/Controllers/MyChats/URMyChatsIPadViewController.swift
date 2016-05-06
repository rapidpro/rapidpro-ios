//
//  URMyChatsIPadViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 05/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URMyChatsIPadViewController: UISplitViewController, URMyChatsViewControllerDelegate {

    let myChatsViewController = URMyChatsViewController()
    var messagesViewController = URMessagesViewController(chatRoom: nil, chatMembers: [], title: nil)
    
    var myChatsBarButtonItens:[UIBarButtonItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .AllVisible
        self.extendedLayoutIncludesOpaqueBars = true
        
        myChatsViewController.delegate = self
        setupViewControllers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.translucent = false
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.tabBarController?.tabBar.translucent = false
    }
    
    //MARK: URMyChatsViewControllerDelegate
    
    func openChatRoomWith(chatRoom: URChatRoom, chatMembers: [URUser], title: String) {
        
        self.messagesViewController.chatRoom = chatRoom
        self.messagesViewController.chatMembers = chatMembers
        self.messagesViewController.navigationTitle = title
        self.messagesViewController.loadMessagesController()

    }
    
    //MARK: Class Methods
    
    func setupViewControllers() {
        
        let leftNavigationController = UINavigationController(rootViewController: myChatsViewController)
        setupNavigationDefaultAtrributes(leftNavigationController)
        
        let rightNavigationController = UINavigationController(rootViewController: messagesViewController)
        setupNavigationDefaultAtrributes(rightNavigationController)
        
        self.viewControllers = [leftNavigationController,rightNavigationController]
        myChatsViewController.navigationItem.rightBarButtonItems = myChatsBarButtonItens
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
