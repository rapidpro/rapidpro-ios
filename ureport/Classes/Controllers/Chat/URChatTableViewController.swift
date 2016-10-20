//
//  URMyChatsTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
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


protocol URChatTableViewControllerDelegate {
    func openChatRoom(_ chatRoom: URChatRoom,chatMembers:[URUser], title:String)
    func openNewGroupViewController(_ newGroupViewController:URNewGroupViewController)
}

class URChatTableViewController: UITableViewController, URChatRoomManagerDelegate, UISearchBarDelegate, URNewGroupTableViewCellDelegate {

    var createGroupOption:Bool!
    var listUser:[URUser] = []
    var listFilteredUser:[URUser] = []
    var listAuxUser:[URUser] = []
    
    var chatRoomManager = URChatRoomManager()
    var delegate:URChatTableViewControllerDelegate?
    
    var searchController:UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
        self.tableView.register(UINib(nibName: "URNewGroupTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URNewGroupTableViewCell.self))
        
        chatRoomManager.delegate = self
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = addSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)
        self.loadData()                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        MBProgressHUD.hide(for: self.view, animated: true)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchController!.searchBar.text!.isEmpty {
            
            let listFiltered = listUser.filter({return $0.nickname.range(of: searchController!.searchBar.text!, options: NSString.CompareOptions.caseInsensitive) != nil})
            
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        listUser = listAuxUser
        self.tableView.reloadData()
    }
    
    //MARK: URChatRoomManagerDelegate
    
    func openChatRoom(_ chatRoom: URChatRoom, members: [URUser], title: String) {
        MBProgressHUD.hide(for: self.view, animated: true)
        if let delegate = delegate {
            delegate.openChatRoom(chatRoom, chatMembers: members, title: title)
        }else{
            self.navigationController?.pushViewController(URMessagesViewController(chatRoom: chatRoom, chatMembers: members, title: title), animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.createGroupOption == true && URUserManager.userHasPermissionToAccessTheFeature(true)){
            return 65
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader =  Bundle.main.loadNibNamed("URNewGroupTableViewCell", owner: 0, options: nil)?[0] as! URNewGroupTableViewCell
        viewHeader.delegate = self

        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0))
        
        if ((self.createGroupOption == true && URUserManager.userHasPermissionToAccessTheFeature(true))){
            
            let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 65)
            viewHeader.frame = frame
            
            view.addSubview(viewHeader)
            
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {                
        return self.listUser.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URChatTableViewCell.self), for: indexPath) as! URChatTableViewCell

        cell.setupCellWithUser(self.listUser[(indexPath as NSIndexPath).row],createGroupOption: self.createGroupOption, indexPath: indexPath, checkGroupOption: false)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! URChatTableViewCell
        
        if (cell.type != .group || cell.type != .individual) && cell.chatRoom == nil{

            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            chatRoomManager.createIndividualChatRoomIfPossible(cell.user!, isIndividualChatRoom: true)
            
        }else {
            if let chatRoom = cell.chatRoom {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                URGCMManager.registerUserInTopic(URUser.activeUser()!, chatRoom: chatRoom)
                URUserManager.updateChatroom(URUser.activeUser()!, chatRoom: chatRoom)
                URChatMemberManager.getChatMembersByChatRoomWithCompletion(chatRoom.key, completionWithUsers: { (users) -> Void in
                MBProgressHUD.hide(for: self.view, animated: true)
                    
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
    
    func createNewGroupCellDidTap(_ cell: URNewGroupTableViewCell) {
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
        
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        self.tableView.tableHeaderView = headerView
    }
    
    func loadData() {
        if listUser.count == 0 {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        URUserManager.getAllUserByCountryProgram({ (users:[URUser]?) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if users != nil && !users!.isEmpty {
                self.listUser = users!
                
                let userSortedList = self.listUser.sorted(by: { (user1, user2) -> Bool in
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
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(URConstant.isIpad ? 0 : 64, 0.0, self.tabBarController != nil ? self.tabBarController!.tabBar.frame.height : 0.0, 0.0);
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorColor = UIColor.clear
    }
}
