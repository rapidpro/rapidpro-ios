//
//  URModerationViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 28/10/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class URModerationViewController: UITabBarController, UITabBarControllerDelegate {

    var appDelegate:AppDelegate!
    
    lazy var readerVC = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    let storyViewController:URStoriesTableViewController = URStoriesTableViewController(filterStoriesToModerate: true)
    let moderatorViewController:URModeratorTableViewController = URModeratorTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.appDelegate.requestPermissionForPushNotification(UIApplication.sharedApplication())
        
        setupViewControllers()
        tabBarController(self, didSelectViewController: storyViewController)
        
    }

    //MARK: Class Methods
    
    func openQRCodeReader() {
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            URBackendAuthManager.saveAuthToken(result!.value, completion: { (success) in
                self.readerVC.dismissViewControllerAnimated(true, completion: { })
            })
        }
        
        readerVC.modalPresentationStyle = .FormSheet
        self.presentViewController(readerVC, animated: true) { }
    }
    
    func setupViewControllers() {
        
        storyViewController.title = "main_stories".localized
        storyViewController.tabBarItem.image = UIImage(named: "icon_stories")
                
        moderatorViewController.title = "label_country_moderator".localized
        moderatorViewController.tabBarItem.image = UIImage(named: "manageMod")
        
        if URUser.activeUser()!.masterModerator != nil && URUser.activeUser()!.masterModerator == true {
            self.viewControllers = [storyViewController,moderatorViewController]
        }else {
            self.viewControllers = [storyViewController]
        }
    }
    
    //MARK: TabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        let qrCodeBarButton = UIBarButtonItem(image: UIImage(named: "ic_qrcode"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(openQRCodeReader))
        
        if viewController is URStoriesTableViewController {
            self.title = viewController.title
            self.navigationItem.rightBarButtonItems = [qrCodeBarButton]
        }
        
        if viewController is URModeratorTableViewController {
            self.title = viewController.title
            self.navigationItem.rightBarButtonItems = [qrCodeBarButton]
        }
        
    }
    
}
