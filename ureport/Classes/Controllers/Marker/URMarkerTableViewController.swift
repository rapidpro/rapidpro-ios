//
//  URMarkerTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URMarkerTableViewControllerDelegate {
    func markersList(markers:[URMarker])
}

class URMarkerTableViewController: UITableViewController, MarkerTableViewCellDelegate, AddMarkerTableViewCellDelegate {

    var markerList:[URMarker] = []
    var markerListTapped:[URMarker] = []
    var delegate:URMarkerTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        markerList = URMarkerManager.getMarkers()
        setupTableView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let delegate = self.delegate {
            if !markerListTapped.isEmpty {
                delegate.markersList(markerListTapped)
            }
        }
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markerList.count + 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? URMarkerTableViewCell {
            self.markerHasTapped(cell)
            self.view.endEditing(true)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == markerList.count {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URAddMarkerTableViewCell.self), forIndexPath: indexPath) as! URAddMarkerTableViewCell
            cell.delegate = self
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(URMarkerTableViewCell.self), forIndexPath: indexPath) as! URMarkerTableViewCell
            cell.delegate = self
            let marker = markerList[indexPath.row]
            
            if let _ = markerListTapped.indexOf(marker) {
                cell.setBtCheckSelected(true)
            }else {
                cell.setBtCheckSelected(false)
            }
            
            cell.setupCellWith(marker)
            return cell
        }
        
    }
    
    //MARK: Class Methods
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        
        self.tableView.registerNib(UINib(nibName: "URMarkerTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URMarkerTableViewCell.self))
        
        self.tableView.registerNib(UINib(nibName: "URAddMarkerTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URAddMarkerTableViewCell.self))
        
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    //MARK: AddMarkerTableViewCellDelegate
    
    func newMarkerAdded(marker: URMarker) {
        URMarkerManager.saveMarker(marker)
        markerList.append(marker)
        let indexPath = NSIndexPath(forRow: markerList.count-1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    //MARK: MarkerTableViewCellDelegate
    
    func markerHasTapped(cell:URMarkerTableViewCell) {
        
        if let index = markerListTapped.indexOf(cell.marker) {
            markerListTapped.removeAtIndex(index)
            cell.setBtCheckSelected(false)
        }else {
            cell.setBtCheckSelected(true)
            markerListTapped.append(cell.marker)
        }        
    }
    
}
