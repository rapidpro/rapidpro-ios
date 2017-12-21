//
//  UITableViewExtension.swift
//  ureport
//
//  Created by Yves Bastos on 21/12/2017.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit

extension UITableView {
    func addRefreshControl(target: Any, selector: Selector) {
        let tvRefreshControl = UIRefreshControl()
        tvRefreshControl.tag = 88101
        tvRefreshControl.addTarget(target, action: selector, for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            self.refreshControl = tvRefreshControl
        } else {
            self.addSubview(tvRefreshControl)
        }
    }
    
    func setRefreshControlTo(animate: Bool) {
        var tvRefreshControl: UIRefreshControl?
        
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                tvRefreshControl = self.refreshControl
            } else {
                tvRefreshControl = self.viewWithTag(88101) as? UIRefreshControl
            }
            
            if animate {
                let controlHeight = tvRefreshControl?.frame.height ?? 0
                self.setContentOffset(CGPoint(x: 0, y: -controlHeight), animated: true)
                tvRefreshControl?.beginRefreshing()
            } else {
                tvRefreshControl?.endRefreshing()
            }            
        }
    }
}
