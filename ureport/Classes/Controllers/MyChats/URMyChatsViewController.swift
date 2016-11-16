//
//  URMyChatsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 15/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import MBProgressHUD
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol URMyChatsViewControllerDelegate {
    func openChatRoomWith(_ chatRoom:URChatRoom,chatMembers:[URUser],title:String)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBadgeMyChatsViewController), name:NSNotification.Name(rawValue: "newChatReceived"), object: nil)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "My Chats")
        
        let builder = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as [NSObject : AnyObject]!)
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openChatRoomWithKey(chatRoomKeyToOpen)
        chatRoomKeyToOpen = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)    
    }
    
    //MARK: URGroupsTableViewCellDelegate
    
    func btJoinDidTap(_ cell: URGroupsTableViewCell, groupChatRoom: URGroupChatRoom, members: [URUser],title:String) {
        if let delegate = self.delegate {
            delegate.openChatRoomWith(groupChatRoom, chatMembers: members, title: title)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listChatRoom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URChatTableViewCell.self), for: indexPath) as! URChatTableViewCell
        
        cell.setupCellWithChatRoom(self.listChatRoom[(indexPath as NSIndexPath).row])        
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if currentChatRoom != nil {
            if cell.chatRoom?.key == currentChatRoom?.key {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! URChatTableViewCell
        
        self.currentChatRoom = cell.chatRoom
        
        cell.viewUnreadMessages.isHidden = true
        
        if let chatRoom = cell.chatRoom {
            URGCMManager.registerUserInTopic(URUser.activeUser()!, chatRoom: chatRoom)
            openChatRoom(chatRoom)
        }
        
    }

    //MARK: Button Events
    
    @IBAction func btSeeTapped(_ sender: AnyObject) {
        let groupsTableViewController = URGroupsTableViewController()
        groupsTableViewController.myChatsViewController = self
        self.navigationController?.pushViewController(groupsTableViewController, animated: true)
    }
    
    
    //MARK: Class Methods
    
    func addBadgeMyChatsViewController() {
        loadData()
    }
    
    func openChatRoomWithKey(_ chatRoomKey: String?) {
        if chatRoomKey != nil {
            URChatRoomManager.getByKey(chatRoomKey!, completion: { (chatRoom) -> Void in
                self.openChatRoom(chatRoom!)
            })
        }
    }
    
    func openChatRoom(_ chatRoom: URChatRoom) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key!, completionWithUsers: { (users) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            var chatName = ""
            
            if chatRoom is URIndividualChatRoom {
                let friend = self.getFriend(users)
                chatName = friend!.nickname!
            }else if chatRoom is URGroupChatRoom {
                chatName = (chatRoom as! URGroupChatRoom).title
            }
            
            if let delegate = self.delegate {
                delegate.openChatRoomWith(chatRoom, chatMembers: users, title: chatName)
            }
            
        })
    }
    
    func getFriend(_ users:[URUser]) -> URUser? {
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
        self.btSee.setTitle("title_see".localized, for: UIControlState())
        
        btSee.layer.cornerRadius = 4
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.separatorColor = UIColor.clear
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.tableView.register(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    func markCellThatChatIsOpen(_ chatRoom:URChatRoom) {        
        self.currentChatRoom = chatRoom
        loadData()
    }
    
    func loadData() {
        if listChatRoom.count == 0 && URUser.activeUser()?.chatRooms?.count > 0{
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        URChatRoomManager.getChatRooms(URUser.activeUser()!, completion: { (chatRooms:[URChatRoom]?) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if chatRooms != nil {
                
                self.lbMessage.isHidden = true
                
                let index = self.listChatRoom.index{($0.key == chatRooms!.last!.key)}
                
                if index == nil {
                    self.listChatRoom.insert(chatRooms!.last!, at: self.listChatRoom.count)
                    
                    self.tableView.insertRows(at: [IndexPath(row: self.listChatRoom.count - 1, section: 0)], with: UITableViewRowAnimation.fade)
                    
                }else {
                    self.listChatRoom.remove(at: index!)
                    self.listChatRoom.insert(chatRooms!.last!, at: index!)
                    self.tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: UITableViewRowAnimation.none)
                }
                
                if self.listChatRoom.count == chatRooms?.count {
                    self.listChatRoom = self.listChatRoom.sorted{($0.0.lastMessage?.date.intValue > $0.1.lastMessage?.date.intValue)}
                    self.tableView.reloadData()
                }
                
            }else{
                self.lbMessage.isHidden = false
            }
        })
    }
    
}
