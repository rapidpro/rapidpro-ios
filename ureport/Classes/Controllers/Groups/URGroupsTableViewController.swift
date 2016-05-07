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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        listGroups = []
        
        chatRoomManager.delegate = self
        chatRoomManager.getOpenGroups()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Open Groups")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listGroups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URGroupsTableViewCell.self), forIndexPath: indexPath) as! URGroupsTableViewCell
        
        if !URConstant.isIpad {
            cell.delegate = self
        }else{
            cell.delegate = myChatsViewController
        }
        
        cell.setupCellWithData(listGroups[indexPath.row])
        
        return cell
    }
    
    //MARK: URGroupsTableViewCellDelegate
    
    func btJoinDidTap(cell: URGroupsTableViewCell, groupChatRoom: URGroupChatRoom, members: [URUser], title:String) {
        self.navigationController?.pushViewController(URMessagesViewController(chatRoom: groupChatRoom, chatMembers: members, title: title),animated:true)
    }
    
    //MARK: UTChatRoomManagerDelegate
    
    func newOpenGroupReceived(groupChatRoom: URGroupChatRoom) {
        listGroups.append(groupChatRoom)
        tableView.reloadData()
    }
    
    //MARK: Class Methods
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.registerNib(UINib(nibName: "URGroupsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URGroupsTableViewCell.self))
        self.tableView.separatorColor = UIColor.groupTableViewBackgroundColor()
    }
}
