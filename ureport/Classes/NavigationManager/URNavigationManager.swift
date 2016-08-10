//
//  URNavigationManager.swift
//  ureport
//
//  Created by Daniel Amaral on 29/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

enum URNavigationBarType {
    case Clear
    case Blue
    case Yellow
}

class URNavigationManager: NSObject, SWRevealViewControllerDelegate {

    static var navigation:UINavigationController!
    static var revealController:SWRevealViewController!
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var sidebarMenuOpen:Bool!
    
    static let instance = URNavigationManager()
    
    class func sharedInstance() -> URNavigationManager{
        return instance
    }
    
    class func setupNavigationControllerWithMainViewController(viewController:UIViewController) {
        
        let menuViewController:ISMenuViewController = ISMenuViewController()
        
        URNavigationManager.addLeftButtonMenuInViewController(viewController)
        
        self.navigation = UINavigationController(rootViewController: viewController)
        URNavigationManager.setupNavigationDefaultAtrributes()
        self.navigation!.navigationBar.translucent = true
        
        self.revealController = SWRevealViewController(rearViewController: menuViewController, frontViewController: self.navigation)
        self.revealController!.rearViewRevealWidth = 250
        self.revealController!.delegate = URNavigationManager.sharedInstance()
        
        viewController.view.userInteractionEnabled = true
        viewController.view.addGestureRecognizer(self.revealController!.panGestureRecognizer())
        
        URNavigationManager.switchRootViewController(self.revealController!, animated: true, completion: nil)
        appDelegate.window?.makeKeyAndVisible()
        
    }
    
    class func setFrontViewController(viewController:UIViewController){
        viewController.view.userInteractionEnabled = true
        viewController.view.addGestureRecognizer(self.revealController!.panGestureRecognizer())
        URNavigationManager.addLeftButtonMenuInViewController(viewController)
        self.navigation?.viewControllers = [viewController]
        self.revealController?.pushFrontViewController(self.navigation, animated: true)
    }
    
    class func setupNavigationControllerWithLoginViewController() {
        
        self.navigation = UINavigationController(rootViewController: URLoginViewController())
        URNavigationManager.setupNavigationDefaultAtrributes()
        self.navigation!.navigationBar.translucent = false
        self.navigation!.setNavigationBarHidden(true, animated: false)
        
        URNavigationManager.switchRootViewController(self.navigation!, animated: true, completion: nil)
        appDelegate.window?.makeKeyAndVisible()
    }
    
    class func setupNavigationControllerWithTutorialViewController() {
        
        let tutorialViewController = URTutorialViewController()
        
        self.navigation = UINavigationController(rootViewController: tutorialViewController)
        URNavigationManager.setupNavigationDefaultAtrributes()
        self.navigation!.navigationBar.translucent = false
        self.navigation!.setNavigationBarHidden(true, animated: false)
        
        URNavigationManager.switchRootViewController(self.navigation!, animated: true, completion: nil)
        appDelegate.window?.makeKeyAndVisible()
    }
    
    class func setupNavigationDefaultAtrributes() {
        self.navigation!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName:UIFont(name: "Avenir-Light", size: 20) as! AnyObject
        ]
        
        self.navigation.navigationBar.tintColor = UIColor.whiteColor()
        self.navigation.navigationBar.shadowImage = UIImage()
        self.navigation.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigation.navigationBar.translucent = true
    }
    
    class func setupNavigationBarWithType(type:URNavigationBarType) {        
        switch type {
        case .Clear:
            UIView.animateWithDuration(0, animations: { () -> Void in
                self.navigation.navigationBar.shadowImage = UIImage()
                self.navigation.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            })
        break
        case .Blue:
            UIView.animateWithDuration(0, animations: { () -> Void in
                let defaultNavigationController = UINavigationController()
                self.navigation.navigationBar.barTintColor = URConstant.Color.PRIMARY
                self.navigation.navigationBar.shadowImage = defaultNavigationController.navigationBar.shadowImage
                self.navigation.navigationBar.setBackgroundImage(defaultNavigationController.navigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            })
        break
        case .Yellow:
            UIView.animateWithDuration(0, animations: { () -> Void in
                let defaultNavigationController = UINavigationController()
                self.navigation.navigationBar.barTintColor = URConstant.Color.YELLOW
                self.navigation.navigationBar.shadowImage = defaultNavigationController.navigationBar.shadowImage
                self.navigation.navigationBar.setBackgroundImage(defaultNavigationController.navigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
            })
        break
            
        }
    }
    
    class func setupNavigationBarWithCustomColor(color:UIColor) {
        let defaultNavigationController = UINavigationController()
        self.navigation.navigationBar.barTintColor = color
        self.navigation.navigationBar.shadowImage = defaultNavigationController.navigationBar.shadowImage
        self.navigation.navigationBar.setBackgroundImage(defaultNavigationController.navigationBar.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
    }
    
    class func addLeftButtonMenuInViewController(viewController:UIViewController){
        let image:UIImage = ISImageUtil.resizeImage(UIImage(named: "icon_burgermenu")!,scaledToSize: CGSize(width: 20, height: 16))
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(toggleMenu))
    }
    
    class func toggleMenu() {
        self.revealController?.revealToggleAnimated(true)
    }
    
    class func switchRootViewController(rootViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if animated {
            UIView.transitionWithView(appDelegate.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                self.appDelegate.window!.rootViewController = rootViewController
                UIView.setAnimationsEnabled(oldState)
                }, completion: { (finished: Bool) -> () in
                    if completion != nil {
                        completion!()
                    }
            })
        } else {
            appDelegate.window!.rootViewController = rootViewController
        }
    }
    
    //MARK SWRevealViewControllerDelegate
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            revealController.frontViewController.view.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            revealController.frontViewController.view.userInteractionEnabled = false
            revealController.frontViewController.revealViewController().tapGestureRecognizer().enabled = true
            revealController.frontViewController.revealViewController().panGestureRecognizer().enabled = true
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            // self.view.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            // self.view.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    
}
