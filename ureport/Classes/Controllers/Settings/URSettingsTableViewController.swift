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
        self.title = "Settings".localized
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        URNavigationManager.setupNavigationBarWithCustomColor(URCountryProgramManager.activeCountryProgram()!.themeColor!)                
    }

    //MARK URSettingsTableViewCellDelegate
    
    func switchEnableDidTapped(cell: URSettingsTableViewCell) {
        let settings = URSettings()
        switch(cell.index) {
        case 0:
            settings.availableInChat = cell.switchEnable.on
            
            URUserManager.updateAvailableInChat(URUser.activeUser()!,publicProfile: cell.switchEnable.on)
            
            break
        default:
            break
        }
        
        URSettings.saveSettingsLocaly(settings)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URSettingsTableViewCell.self), forIndexPath: indexPath) as! URSettingsTableViewCell
        
        cell.delegate = self
        cell.index = indexPath.row
        
        switch indexPath.row {
            case 0:
                cell.switchEnable.hidden = false
                if let settings = URSettings.getSettings() {
                    cell.switchEnable.on = settings.availableInChat.boolValue
                }else {
                    cell.switchEnable.on = true
                }
                cell.lbSettingName.text = "Available in Chat".localized
                break
            case 1:
                cell.switchEnable.hidden = true
                cell.lbSettingName.text = "OpenSource License".localized
            break
            default:
                break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! URSettingsTableViewCell
        
    }
    
    //MARK: Class Methods
    
    private func setupTableView() {
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        
        self.tableView.registerNib(UINib(nibName: "URSettingsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URSettingsTableViewCell.self))
        self.tableView.separatorColor = URConstant.Color.WINDOW_BACKGROUND
    }

}
