//
//  URNewsTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 21/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class URNewsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URNewsTableViewCell.self), forIndexPath: indexPath) as! URNewsTableViewCell
        
        cell.lbTitle.text = "Increasing Immunization Coverage in Uganda"
        cell.lbDescription.text = "Increasing Immunization Coverage in Uganda: The Community Problem-solving and Strategy Development Approach"
        
        switch indexPath.row {
        case 0:
            cell.imgNew.image = UIImage(named: "news1_cover_image.jpg")
            break
        case 1:
            cell.imgNew.image = UIImage(named: "news2_cover_image.jpg")
            break
        case 2:
            cell.imgNew.image = UIImage(named: "news3_cover_image.jpg")
            break
        default:
            print("", terminator: "")
        }
        
        return cell
    }
    
    //MARK: Class Methods
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0)
        self.tableView.backgroundColor = URConstant.Color.WINDOW_BACKGROUND
        self.tableView.registerNib(UINib(nibName: "URNewsTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URNewsTableViewCell.self))
        self.tableView.separatorColor = UIColor.clearColor()
    }
}
