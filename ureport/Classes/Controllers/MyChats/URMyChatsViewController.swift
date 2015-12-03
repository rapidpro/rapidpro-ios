//
//  URMyChatsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 15/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URMyChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var btSee: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbDescriptionOpenGroups: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var listChatRoom:[URChatRoom] = []
    var chatRoomKeyToOpen:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        openChatRoomWithKey(chatRoomKeyToOpen)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)    
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listChatRoom.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URChatTableViewCell.self), forIndexPath: indexPath) as! URChatTableViewCell
        
        cell.setupCellWithChatRoomList(self.listChatRoom, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URChatTableViewCell
                
        if let chatRoom = cell.chatRoom {
            URGCMManager.registerUserInTopic(URUser.activeUser()!, chatRoom: chatRoom)
            openChatRoom(chatRoom)
        }
        
    }

    //MARK: Button Events
    
    @IBAction func btSeeTapped(sender: AnyObject) {
        self.navigationController?.pushViewController(URGroupsTableViewController(), animated: true)
    }
    
    
    //MARK: Class Methods
    
    func openChatRoomWithKey(chatRoomKey: String?) {
        if chatRoomKey != nil {
            URChatRoomManager.getByKey(chatRoomKey!, completion: { (chatRoom) -> Void in
                self.openChatRoom(chatRoom!)
            })
        }
    }
    
    func openChatRoom(chatRoom: URChatRoom) {
        ProgressHUD.show(nil)
        URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key, completionWithUsers: { (users) -> Void in
            ProgressHUD.dismiss()
            
            var chatName = ""
            
            if chatRoom is URIndividualChatRoom {
                let friend = self.getFriend(users)
                chatName = friend!.nickname
            }else if chatRoom is URGroupChatRoom {
                chatName = (chatRoom as! URGroupChatRoom).title
            }
            
            self.navigationController?.pushViewController(URMessagesViewController(chatRoom: chatRoom,chatMembers:users,title:chatName), animated: true)
        })
    }
    
    func getFriend(users:[URUser]) -> URUser? {
        for user in users {
            if user.key != URUser.activeUser()?.key {
                return user
            }
        }
        
        return nil
    }
    
    func setupUI() {
        btSee.layer.cornerRadius = 4
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    func loadData() {
        if listChatRoom.count == 0 {
            ProgressHUD.show(nil)
        }
        
        URChatRoomManager.getChatRooms(URUser.activeUser()!, completion: { (chatRooms:[URChatRoom]?) -> Void in
            ProgressHUD.dismiss()
            if chatRooms != nil {
                self.lbMessage.hidden = true
                self.listChatRoom = chatRooms!
                
                self.tableView.reloadData()
            }else{
                self.lbMessage.hidden = false
            }
        })
    }
    
}
