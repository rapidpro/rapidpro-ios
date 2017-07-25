//
//  URGroupsTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URGroupsTableViewController: UITableViewController, URChatRoomManagerDelegate, URGroupsTableViewCellDelegate {

    let chatRoomManager = URChatRoomManager()
    var listGroups:[URGroupChatRoom] = []
    var myChatsViewController:URMyChatsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        listGroups = []
        
        chatRoomManager.delegate = self
        chatRoomManager.getOpenGroups()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Open Groups")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URGroupsTableViewCell.self), for: indexPath) as! URGroupsTableViewCell
        
        if !URConstant.isIpad {
            cell.delegate = self
        }else{
            cell.delegate = myChatsViewController
        }
        
        cell.setupCellWithData(listGroups[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    //MARK: URGroupsTableViewCellDelegate
    
    func btJoinDidTap(_ cell: URGroupsTableViewCell, groupChatRoom: URGroupChatRoom, members: [URUser], title:String) {
        self.navigationController?.pushViewController(URMessagesViewController(chatRoom: groupChatRoom, chatMembers: members, title: title),animated:true)
    }
    
    //MARK: UTChatRoomManagerDelegate
    
    func newOpenGroupReceived(_ groupChatRoom: URGroupChatRoom) {
        listGroups.append(groupChatRoom)
        tableView.reloadData()
    }
    
    //MARK: Class Methods
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.register(UINib(nibName: "URGroupsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URGroupsTableViewCell.self))
        self.tableView.separatorColor = UIColor.groupTableViewBackground
    }
}
