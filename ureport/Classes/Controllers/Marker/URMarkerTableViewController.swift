//
//  URMarkerTableViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 14/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URMarkerTableViewControllerDelegate {
    func markersList(_ markers:[URMarker])
}

class URMarkerTableViewController: UITableViewController, MarkerTableViewCellDelegate, AddMarkerTableViewCellDelegate {

    var markerList:[URMarker] = []
    var markerListTapped:[URMarker] = []
    var delegate:URMarkerTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let delegate = self.delegate {
            if !markerListTapped.isEmpty {
                delegate.markersList(markerListTapped)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Marker")
        
        if let builder = GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable: Any] {
            tracker?.send(builder)
        }

        markerList = URMarkerManager.getMarkers()
        setupTableView()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return markerList.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? URMarkerTableViewCell {
            self.markerHasTapped(cell)
            self.view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == markerList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URAddMarkerTableViewCell.self), for: indexPath) as! URAddMarkerTableViewCell
            cell.delegate = self
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(URMarkerTableViewCell.self), for: indexPath) as! URMarkerTableViewCell
            cell.delegate = self
            let marker = markerList[(indexPath as NSIndexPath).row]
            
            if let _ = markerListTapped.index(of: marker) {
                cell.setBtCheckSelected(true)
            }else {
                cell.setBtCheckSelected(false)
            }
            
            cell.setupCellWith(marker)
            return cell
        }
        
    }
    
    //MARK: Class Methods
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        
        self.tableView.register(UINib(nibName: "URMarkerTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URMarkerTableViewCell.self))
        
        self.tableView.register(UINib(nibName: "URAddMarkerTableViewCell", bundle: nil), forCellReuseIdentifier: NSStringFromClass(URAddMarkerTableViewCell.self))
        
        self.tableView.separatorColor = UIColor.clear
    }
    
    //MARK: AddMarkerTableViewCellDelegate
    
    func newMarkerAdded(_ marker: URMarker) {
        URMarkerManager.saveMarker(marker)
        markerList.append(marker)
        self.tableView.reloadData()
    }
    
    //MARK: MarkerTableViewCellDelegate
    
    func markerHasTapped(_ cell:URMarkerTableViewCell) {
        if !markerListTapped.isEmpty {
            if let index = markerListTapped.index(of: cell.marker) {
                markerListTapped.remove(at: index)
                cell.setBtCheckSelected(false)
            }else {
                cell.setBtCheckSelected(true)
                markerListTapped.append(cell.marker)
            }
        }else {
            cell.setBtCheckSelected(true)
            markerListTapped.append(cell.marker)
        }
    }
    
}
