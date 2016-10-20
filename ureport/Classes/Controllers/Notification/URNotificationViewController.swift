//
//  URNotificationViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 19/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URNotificationViewController: UIViewController {

    
    @IBOutlet weak var lbNotification: UILabel!
    @IBOutlet weak var btSettings: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Events
    
    
    @IBAction func btSettingsTapped(_ sender: AnyObject) {
        URNavigationManager.setFrontViewController(URSettingsTableViewController())
    }

}
