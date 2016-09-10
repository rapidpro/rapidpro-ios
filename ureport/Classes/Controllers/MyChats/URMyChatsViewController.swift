//
//  URMyChatsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 15/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol URMyChatsViewControllerDelegate {
    func openChatRoomWith(chatRoom:URChatRoom,chatMembers:[URUser],title:String)
}

class URMyChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URGroupsTableViewCellDelegate {

    @IBOutlet weak var btSee: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbDescriptionOpenGroups: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var listChatRoom:[URChatRoom] = []
    var chatRoomKeyToOpen:String?
    
    var currentChatRoom:URChatRoom?
    
    var delegate:URMyChatsViewControllerDelegate?
    
    init() {
        super.init(nibName: "URMyChatsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addBadgeMyChatsViewController), name:"newChatReceived", object: nil)
        
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "My Chats")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        openChatRoomWithKey(chatRoomKeyToOpen)
        chatRoomKeyToOpen = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)    
    }
    
    //MARK: URGroupsTableViewCellDelegate
    
    func btJoinDidTap(cell: URGroupsTableViewCell, groupChatRoom: URGroupChatRoom, members: [URUser],title:String) {
        if let delegate = self.delegate {
            delegate.openChatRoomWith(groupChatRoom, chatMembers: members, title: title)
        }
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
        
        cell.setupCellWithChatRoom(self.listChatRoom[indexPath.row])        
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if currentChatRoom != nil {
            if cell.chatRoom?.key == currentChatRoom?.key {
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URChatTableViewCell
        
        self.currentChatRoom = cell.chatRoom
        
        cell.viewUnreadMessages.hidden = true
        
        if let chatRoom = cell.chatRoom {
            URGCMManager.registerUserInTopic(URUser.activeUser()!, chatRoom: chatRoom)
            openChatRoom(chatRoom)
        }
        
    }

    //MARK: Button Events
    
    @IBAction func btSeeTapped(sender: AnyObject) {
        let groupsTableViewController = URGroupsTableViewController()
        groupsTableViewController.myChatsViewController = self
        self.navigationController?.pushViewController(groupsTableViewController, animated: true)
    }
    
    
    //MARK: Class Methods
    
    func addBadgeMyChatsViewController() {
        loadData()
    }
    
    func openChatRoomWithKey(chatRoomKey: String?) {
        if chatRoomKey != nil {
            URChatRoomManager.getByKey(chatRoomKey!, completion: { (chatRoom) -> Void in
                self.openChatRoom(chatRoom!)
            })
        }
    }
    
    func openChatRoom(chatRoom: URChatRoom) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key, completionWithUsers: { (users) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            var chatName = ""
            
            if chatRoom is URIndividualChatRoom {
                let friend = self.getFriend(users)
                chatName = friend!.nickname
            }else if chatRoom is URGroupChatRoom {
                chatName = (chatRoom as! URGroupChatRoom).title
            }
            
            if let delegate = self.delegate {
                delegate.openChatRoomWith(chatRoom, chatMembers: users, title: chatName)
            }
            
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
        
        self.lbTitle.text = "label_chat_groups".localized
        self.lbDescriptionOpenGroups.text = "description_open_groups".localized
        self.btSee.setTitle("title_see".localized, forState: UIControlState.Normal)
        
        btSee.layer.cornerRadius = 4
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.tableView.registerNib(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    func markCellThatChatIsOpen(chatRoom:URChatRoom) {        
        self.currentChatRoom = chatRoom
        loadData()
    }
    
    func loadData() {
        if listChatRoom.count == 0 && URUser.activeUser()?.chatRooms?.count > 0{
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        URChatRoomManager.getChatRooms(URUser.activeUser()!, completion: { (chatRooms:[URChatRoom]?) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if chatRooms != nil {
                
                self.lbMessage.hidden = true
                
                let index = self.listChatRoom.indexOf{($0.key == chatRooms!.last!.key)}
                
                if index == nil {
                    self.listChatRoom.insert(chatRooms!.last!, atIndex: self.listChatRoom.count)
                    
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.listChatRoom.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    
                }else {
                    self.listChatRoom.removeAtIndex(index!)
                    self.listChatRoom.insert(chatRooms!.last!, atIndex: index!)
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                }
                
                if self.listChatRoom.count == chatRooms?.count {
                    self.listChatRoom = self.listChatRoom.sort{($0.0.lastMessage?.date.integerValue > $0.1.lastMessage?.date.integerValue)}
                    self.tableView.reloadData()
                }
                
            }else{
                self.lbMessage.hidden = false
            }
        })
    }
    
}
