//
//  URModeratorTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 28/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URModeratorTableViewController: UITableViewController, URChatTableViewCellDelegate {

    var listUserSelectedAsModerator:[String] = []
    var listUser:[URUser] = []
    var listCurrentModerators:[String] = []
    var listUserAux:[URUser] = []
    
    var isOptionSelectedUserAsModeratorActive:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isOptionSelectedUserAsModeratorActive = false
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerNib(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithType(.Blue)
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTableView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listUser.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URChatTableViewCell.self), forIndexPath: indexPath) as! URChatTableViewCell
        
        cell.delegate = self
        cell.setupCellWithUserList(self.listUser,createGroupOption: false, myChatsMode: false, indexPath: indexPath, checkGroupOption: true)
        
        let filtered = self.listUserSelectedAsModerator.filter {
            return $0 == self.listUser[indexPath.row].key
        }
                
        if !filtered.isEmpty {
            cell.setBtCheckSelected(true)
        }else{
            cell.setBtCheckSelected(false)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URChatTableViewCell
        self.userSelected(cell.user!)
    }
    
    //MARK: URChatTableViewCellDelegate
    
    func userSelected(user: URUser) {
        
        let filtered = listUserSelectedAsModerator.filter {
            return $0 as String == user.key
        }
        
        if !filtered.isEmpty {
            URUserManager.removeModerateUser(filtered[0])
            listUserSelectedAsModerator.removeAtIndex(listUserSelectedAsModerator.indexOf(filtered[0])!)
        }else{
            if isOptionSelectedUserAsModeratorActive == false {
                URUserManager.setUserAsModerator(user.key)
            }
            listUserSelectedAsModerator.append(user.key)
        }
        
        self.tableView.reloadData()
        
    }
    
    //MARK: Class Methods
    
    func putSelectedUserAsModerator(user:URUser) {
        isOptionSelectedUserAsModeratorActive = true
        self.userSelected(user)
    }
    
    func setUserAsModerator(userKey:String) {
        URUserManager.setUserAsModerator(userKey)
    }
    
    func removeMySelfFromMembers() {
        
        let filteredModeratorUser = self.listUserSelectedAsModerator.filter {
            return $0 != URUser.activeUser()!.key
        }
        
        let filteredUser = self.listUser.filter {
            return $0.key != URUser.activeUser()!.key
        }
        
        self.listUserSelectedAsModerator = filteredModeratorUser
        self.listUser = filteredUser
        self.listUserAux = listUser
        self.tableView.reloadData()
    }
    
    func loadData() {
        ProgressHUD.show(nil)
        
        URUserManager.getAllUserByCountryProgram({ (users:[URUser]?) -> Void in
            ProgressHUD.dismiss()
            
            if users != nil && !users!.isEmpty {
                self.listUser = users!.sort({$0.nickname < $1.nickname})
                
                for i in 0...self.listUser.count-1 {
                    if self.listUser[i].key == URUser.activeUser()!.key {
                        self.listUser.removeAtIndex(i)
                        break
                    }
                }
                
                URUserManager.getAllModertorUsers { (usersKey) -> Void in
                    if let usersKey = usersKey {
                        
                        self.listCurrentModerators = usersKey
                        
                        for userKey in usersKey {
                            let user = URUser()
                            user.key = userKey
                            self.putSelectedUserAsModerator(user)
                        }
                        
                        self.isOptionSelectedUserAsModeratorActive = false
                        
                    }else {
                        self.tableView.reloadData()
                    }
                }
                
            }
        })
    }

    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0.0, self.tabBarController != nil ? CGRectGetHeight(self.tabBarController!.tabBar.frame) : 0.0, 0.0);
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.separatorColor = UIColor.clearColor()
    }
}
