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
    
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true
    })
    
    let storyViewController:URStoriesTableViewController = URStoriesTableViewController(filterStoriesToModerate: true)
    let moderatorViewController:URModeratorTableViewController = URModeratorTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appDelegate.requestPermissionForPushNotification(UIApplication.shared)
        
        setupViewControllers()
        tabBarController(self, didSelect: storyViewController)
        
    }

    //MARK: Class Methods
    
    func openQRCodeReader() {
        reader.completionBlock = { (result: QRCodeReaderResult?) in
            
            self.reader.dismiss(animated: true, completion: { })
            
            if result != nil {
                URBackendAuthManager.saveAuthToken(result!.value, completion: { (success) in
                })
            }
        }
        
        reader.modalPresentationStyle = .formSheet
        self.present(reader, animated: true) { }
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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let qrCodeBarButton = UIBarButtonItem(image: UIImage(named: "ic_qrcode"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(openQRCodeReader))
        
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
