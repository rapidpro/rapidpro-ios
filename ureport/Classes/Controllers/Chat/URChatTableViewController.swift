//
//  URMyChatsTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URChatTableViewControllerDelegate {
    func openChatRoom(chatRoom: URChatRoom,chatMembers:[URUser], title:String)
    func openNewGroupViewController(newGroupViewController:URNewGroupViewController)
}

class URChatTableViewController: UITableViewController, URChatRoomManagerDelegate, UISearchBarDelegate, URNewGroupTableViewCellDelegate {

    var createGroupOption:Bool!
    var myChatsMode:Bool!
    var listUser:[URUser] = []
    var listFilteredUser:[URUser] = []
    var listAuxUser:[URUser] = []
    
    var chatRoomManager = URChatRoomManager()
    var delegate:URChatTableViewControllerDelegate?
    
    var searchController:UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
        self.tableView.registerNib(UINib(nibName: "URNewGroupTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URNewGroupTableViewCell.self))
        
        chatRoomManager.delegate = self
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = addSearchController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        self.loadData()                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTableView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        ProgressHUD.dismiss()
    }
    
    init() {
        super.init(nibName: nil, bundle:nil)
    }
    
    init(createGroupOption:Bool) {
        self.createGroupOption = createGroupOption
        super.init(nibName: nil, bundle:nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }        
    
    //MARK: SearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchController!.searchBar.text!.isEmpty {
            
            let listFiltered = listUser.filter({return $0.nickname.rangeOfString(searchController!.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil})
            
            if !listFiltered.isEmpty {
                listUser = listFiltered
            }else {
                listUser = listAuxUser
            }
            
        }else {
            listUser = listAuxUser
        }
        
        self.tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        listUser = listAuxUser
        self.tableView.reloadData()
    }
    
    //MARK: URChatRoomManagerDelegate
    
    func openChatRoom(chatRoom: URChatRoom, members: [URUser], title: String) {
        if let delegate = delegate {
            delegate.openChatRoom(chatRoom, chatMembers: members, title: title)
        }else{
            self.navigationController?.pushViewController(URMessagesViewController(chatRoom: chatRoom, chatMembers: members, title: title), animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.createGroupOption == true && URUserManager.userHasPermissionToAccessTheFeature(true)){
            return 65
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader =  NSBundle.mainBundle().loadNibNamed("URNewGroupTableViewCell", owner: 0, options: nil)[0] as! URNewGroupTableViewCell
        viewHeader.delegate = self

        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0))
        
        if ((self.createGroupOption == true && URUserManager.userHasPermissionToAccessTheFeature(true))){
            
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 65)
            viewHeader.frame = frame
            
            view.addSubview(viewHeader)
            
        }
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {                
        return self.listUser.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URChatTableViewCell.self), forIndexPath: indexPath) as! URChatTableViewCell

        cell.setupCellWithUser(self.listUser[indexPath.row],createGroupOption: self.createGroupOption, indexPath: indexPath, checkGroupOption: false)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URChatTableViewCell
        
        if (cell.type != .Group || cell.type != .Individual) && cell.chatRoom == nil{

            ProgressHUD.show(nil)
            
            chatRoomManager.createIndividualChatRoomIfPossible(cell.user!)
            
        }else {
            if let chatRoom = cell.chatRoom {
                ProgressHUD.show(nil)
                URGCMManager.registerUserInTopic(URUser.activeUser()!, chatRoom: chatRoom)
                URUserManager.updateChatroom(URUser.activeUser()!, chatRoom: chatRoom)
                URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key, completionWithUsers: { (users) -> Void in
                ProgressHUD.dismiss()
                    
                    var chatName = ""
                    
                    if chatRoom is URIndividualChatRoom {
                        chatName = (chatRoom as! URIndividualChatRoom).friend.nickname
                    }else if chatRoom is URGroupChatRoom {
                        chatName = (chatRoom as! URGroupChatRoom).title
                    }
                    
                    if let delegate = self.delegate {
                        delegate.openChatRoom(chatRoom, chatMembers: users, title: chatName)
                    }else{
                        self.navigationController?.pushViewController(URMessagesViewController(chatRoom: chatRoom, chatMembers: users, title: chatName), animated: true)
                    }
                    
                })
            }
        }
        
    }
    
    //MARK: URNewGroupTableViewCellDelegate
    
    func createNewGroupCellDidTap(cell: URNewGroupTableViewCell) {
        let groupViewController = URNewGroupViewController()
        groupViewController.listUser = self.listUser
        
        if let delegate = self.delegate {
            delegate.openNewGroupViewController(groupViewController)
        }else{
            self.navigationController?.pushViewController(groupViewController, animated: true)
        }
    }
    
    //MARK: Class Methods
    
    func sizeHeaderToFit() {
        let headerView = self.tableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        self.tableView.tableHeaderView = headerView
    }
    
    func loadData() {
        if listUser.count == 0 {
            ProgressHUD.show(nil)
        }
        URUserManager.getAllUserByCountryProgram({ (users:[URUser]?) -> Void in
            ProgressHUD.dismiss()
            
            if users != nil && !users!.isEmpty {
                self.listUser = users!
                
                for i in 0...self.listUser.count-1 {
                    
                    let user = self.listUser[i]
                    
                    if self.listUser[i].key == URUser.activeUser()!.key {
                        self.listUser.removeAtIndex(i)
                        break
                    }
                    
                    if let publicProfile = user.publicProfile {
                        if (Bool(publicProfile) == false) {
                            self.listUser.removeAtIndex(i)
                        }
                    }else {
                        self.listUser.removeAtIndex(i)
                    }
                }
                
                let userSortedList = self.listUser.sort({ (user1, user2) -> Bool in
                    return user1.nickname < user2.nickname
                })
                
                self.listUser = userSortedList
                self.listAuxUser = self.listUser
                self.tableView.reloadData()
            }
        })
    }
    
    func addSearchController() -> UISearchBar {
        
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
            searchController!.hidesNavigationBarDuringPresentation = false
            searchController!.dimsBackgroundDuringPresentation = false
            searchController!.searchBar.sizeToFit()
            searchController!.searchBar.delegate = self
        }
        return searchController!.searchBar
    }
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(URConstant.isIpad ? 0 : 64, 0.0, self.tabBarController != nil ? CGRectGetHeight(self.tabBarController!.tabBar.frame) : 0.0, 0.0);
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorColor = UIColor.clearColor()
    }
}
