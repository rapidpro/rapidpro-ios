 //
//  URMyChatsViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 15/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import MBProgressHUD
import fcm_channel_ios
import IlhasoftCore
 
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

    private struct Constants {
        static let chatRowHeight: CGFloat = 65
    }

    @IBOutlet weak var btSee: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbDescriptionOpenGroups: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var listChatRoom:[AnyObject] = []
    var chatRoomKeyToOpen:String?

    var currentChatRoom:URChatRoom?
    var currentCountryProgram: URCountryProgram?

    var delegate:URMyChatsViewControllerDelegate?

    var newMessage = false
    
    init() {
        super.init(nibName: "URMyChatsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(addBadgeMyChatsViewController), name:NSNotification.Name(rawValue: "newChatReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageReceived), name:NSNotification.Name(rawValue: "newMessageReceived"), object: nil)
        
        currentCountryProgram = URCountryProgramManager.activeCountryProgram()
        if let countryProgram = self.currentCountryProgram {
            self.listChatRoom.append(countryProgram)
        }
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "My Chats")
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openChatRoomWithKey(chatRoomKeyToOpen)
        chatRoomKeyToOpen = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if newMessage {
            newMessage = false
            self.tableView.reloadData()
        }        
    }

    //MARK: URGroupsTableViewCellDelegate

    func btJoinDidTap(_ cell: URGroupsTableViewCell, groupChatRoom: URGroupChatRoom, members: [URUser],title:String) {
        if let delegate = self.delegate {
            delegate.openChatRoomWith(groupChatRoom, chatMembers: members, title: title)
        }
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.chatRowHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listChatRoom.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URChatTableViewCell.self), for: indexPath) as! URChatTableViewCell
        if let countryProgram = self.listChatRoom[indexPath.row] as? URCountryProgram {
            cell.setupCell(withCountryProgram: countryProgram)
            if newMessage {
                cell.viewUnreadMessages.isHidden = false
                cell.viewUnreadMessages.backgroundColor = UIColor.red
                cell.lbUnreadMessages.text = ""
            }
            return cell
        } else {
            let chatRoom = self.listChatRoom[indexPath.row] as! URChatRoom
            cell.setupCellWithChatRoom(chatRoom)
            self.tableView.deselectRow(at: indexPath, animated: true)
            if currentChatRoom != nil {
                if cell.chatRoom?.key == currentChatRoom?.key {
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self.listChatRoom[indexPath.row] as? URCountryProgram {
            if let contact = FCMChannelManager.activeContact() {
                let chatVC = FCMChannelChatViewController(contact: contact, botName: "Bot", loadMessagesOnInit: true)
                self.navigationController?.pushViewController(chatVC, animated: true)
            } else if let user = URUser.activeUser() {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                FCMChannelManager.createContactAndSave(for: user) {
                    contact in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if let contact = contact {
                        let chatVC = FCMChannelChatViewController(contact: contact, botName: "Bot", loadMessagesOnInit: true)
                        self.navigationController?.pushViewController(chatVC, animated: true)
                    } else {
                        ISAlertMessages.displaySimpleMessage("The channel is not configured, contact the country administrator.", fromController: self)
                    }
                }
            } else {
                //TODO:
                print("no active FCM channel contact!")
            }
        } else if let _ = self.listChatRoom[indexPath.row] as? URChatRoom {
            let cell = tableView.cellForRow(at: indexPath) as! URChatTableViewCell
            self.currentChatRoom = cell.chatRoom
            cell.viewUnreadMessages.isHidden = true
            if let chatRoom = cell.chatRoom {
                URGCMManager.registerUserInTopic(URUser.activeUser()!, chatRoom: chatRoom)
                openChatRoom(chatRoom)
            }
        }
    }

    //MARK: Button Events

    @IBAction func btSeeTapped(_ sender: AnyObject) {
        let groupsTableViewController = URGroupsTableViewController()
        groupsTableViewController.myChatsViewController = self
        self.navigationController?.pushViewController(groupsTableViewController, animated: true)
    }

    //MARK: Class Methods

    func newMessageReceived() {
        if let navigationController = self.navigationController {
            if !(navigationController.visibleViewController is FCMChannelChatViewController) {
                newMessage = true
                self.tableView.reloadData()
            }
        }
    }
    
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
            } else if chatRoom is URGroupChatRoom {
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
//        self.tableView.addRefreshControl(target: self, selector: #selector(loadData))
    }

    func markCellThatChatIsOpen(_ chatRoom:URChatRoom) {        
        self.currentChatRoom = chatRoom
        loadData()
    }

    @objc fileprivate func loadData() {
        self.tableView.setRefreshControlTo(animate: true)
        URChatRoomManager.getChatRooms(URUser.activeUser()!, completion: { (chatRooms:[URChatRoom]?) -> Void in
            self.tableView.setRefreshControlTo(animate: false)
            if chatRooms != nil {
                self.lbMessage.isHidden = true
                let index = self.listChatRoom.index{($0.key != nil && $0.key == chatRooms!.last!.key)}
                if index == nil {
                    self.listChatRoom.insert(chatRooms!.last!, at: self.listChatRoom.count)
                    self.tableView.insertRows(at: [IndexPath(row: self.listChatRoom.count - 1, section: 0)], with: UITableViewRowAnimation.fade)
                }else {
                    self.listChatRoom.remove(at: index!)
                    self.listChatRoom.insert(chatRooms!.last!, at: index!)
                    self.tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: UITableViewRowAnimation.none)
                }
                if self.listChatRoom.count == chatRooms?.count {
                    self.listChatRoom = self.listChatRoom
                        .filter({ return $0 is URChatRoom })
                        .map({ return $0 as! URChatRoom })
                        .sorted{($0.0.lastMessage?.date.intValue > $0.1.lastMessage?.date.intValue)}
                    self.tableView.reloadData()
                }
            } else {
                self.lbMessage.isHidden = false
            }
        })
    }
}
