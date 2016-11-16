//
//  URSettingsTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URSettingsTableViewController: UITableViewController, URSettingsTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        setupTableView()
        self.title = "label_settings".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)                
    }

    //MARK URSettingsTableViewCellDelegate
    
    func switchEnableDidTapped(_ cell: URSettingsTableViewCell) {
        let settings = URSettings()
        switch(cell.index) {
        case 0:
            settings.availableInChat = cell.switchEnable.isOn as NSNumber?
            
            URUserManager.updateAvailableInChat(URUser.activeUser()!,publicProfile: cell.switchEnable.isOn)
            
            break
        default:
            break
        }
        
        URSettings.saveSettingsLocaly(settings)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URSettingsTableViewCell.self), for: indexPath) as! URSettingsTableViewCell
        
        cell.delegate = self
        cell.index = (indexPath as NSIndexPath).row
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.switchEnable.isHidden = false
            
            if let availAbleInChat = URSettings.getSettings().availableInChat {
                cell.switchEnable.isOn = availAbleInChat.boolValue
            }else{
                cell.switchEnable.isOn = true
            }
            
            cell.lbSettingName.text = "title_pref_chat_available".localized
            break
        case 1:
            cell.switchEnable.isHidden = true
            cell.lbSettingName.text = "OpenSource License"
            break
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URSettingsTableViewCell
        
    }
    
    //MARK: Class Methods
    
    fileprivate func setupTableView() {
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        
        self.tableView.register(UINib(nibName: "URSettingsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URSettingsTableViewCell.self))
        self.tableView.separatorColor = UIColor.groupTableViewBackground
    }

}
