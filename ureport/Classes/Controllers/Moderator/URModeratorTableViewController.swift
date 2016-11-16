//
//  URModeratorTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 28/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
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


class URModeratorTableViewController: UITableViewController, URChatTableViewCellDelegate {

    var listUserSelectedAsModerator:[String] = []
    var listUser:[URUser] = []
    var listCurrentModerators:[String] = []
    var listUserAux:[URUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "URChatTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URChatTableViewCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)                
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listUser.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URChatTableViewCell.self), for: indexPath) as! URChatTableViewCell
        
        cell.delegate = self
        cell.setupCellWithUser(self.listUser[(indexPath as NSIndexPath).row],createGroupOption: false, indexPath: indexPath, checkGroupOption: true)
        
        let filtered = self.listUserSelectedAsModerator.filter {
            return $0 == self.listUser[(indexPath as NSIndexPath).row].key
        }
                
        if !filtered.isEmpty {
            cell.setBtCheckSelected(true)
        }else{
            cell.setBtCheckSelected(false)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! URChatTableViewCell
        self.userSelected(cell.user!)
    }
    
    //MARK: URChatTableViewCellDelegate
    
    func userSelected(_ user: URUser) {
        
        let filtered = listUserSelectedAsModerator.filter {
            return $0 as String == user.key!
        }
        
        if !filtered.isEmpty {
            URUserManager.removeModerateUser(filtered[0])
            listUserSelectedAsModerator.remove(at: listUserSelectedAsModerator.index(of: filtered[0])!)
        }else{
            URUserManager.setUserAsModerator(user.key)
            listUserSelectedAsModerator.append(user.key)
        }
        
        self.tableView.reloadData()
        
    }
    
    //MARK: Class Methods
    
    func putSelectedUserAsModerator(_ user:URUser) {
        self.userSelected(user)
    }
    
    func setUserAsModerator(_ userKey:String) {
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
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        self.listUserSelectedAsModerator = []
        
        URUserManager.getAllUserByCountryProgram({ (users:[URUser]?) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if users != nil && !users!.isEmpty {
                self.listUser = users!.sorted(by: {$0.nickname < $1.nickname})
                
                for i in 0...self.listUser.count-1 {
                    if self.listUser[i].key == URUser.activeUser()!.key {
                        self.listUser.remove(at: i)
                        break
                    }
                }
                
                self.tableView.reloadData()
                
                URUserManager.getAllModertorUsers { (usersKey) -> Void in
                    if let usersKey = usersKey {
                        
                        self.listCurrentModerators = usersKey
                        
                        for userKey in usersKey {
                            let user = URUser()
                            user.key = userKey
                            self.listUserSelectedAsModerator.append(user.key)
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            }
        })
    }

    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0.0, self.tabBarController != nil ? self.tabBarController!.tabBar.frame.height : 0.0, 0.0);
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.separatorColor = UIColor.clear
    }
}
