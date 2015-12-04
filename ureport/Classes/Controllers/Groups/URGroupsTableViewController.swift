//
//  URGroupsTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URGroupsTableViewController: UITableViewController, URChatRoomManagerDelegate {

    let chatRoomManager = URChatRoomManager()
    var listGroups:[URGroupChatRoom] = []
    
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

        cell.viewController = self
        cell.setupCellWithData(listGroups[indexPath.row])
        
        return cell
    }
    
    //MARK: UTChatRoomManagerDelegate
    
    func newOpenGroupReceived(groupChatRoom: URGroupChatRoom) {
        listGroups.append(groupChatRoom)
        tableView.reloadData()
    }
    
    //MARK: Class Methods
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.registerNib(UINib(nibName: "URGroupsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URGroupsTableViewCell.self))
        self.tableView.separatorColor = URConstant.Color.WINDOW_BACKGROUND
    }
}
