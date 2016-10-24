//
//  URNavigationManager.swift
//  ureport
//
//  Created by Daniel Amaral on 29/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

enum URNavigationBarType {
    case clear
    case blue
    case yellow
}

class URNavigationManager: NSObject, SWRevealViewControllerDelegate {

    static var navigation:UINavigationController!
    static var revealController:SWRevealViewController!
    static var appDelegate:AppDelegate!
    
    var sidebarMenuOpen:Bool!
    
    static let instance = URNavigationManager()
    
    class func sharedInstance() -> URNavigationManager{
        return instance
    }
    
    class func setupNavigationControllerWithMainViewController(_ viewController:UIViewController) {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let menuViewController:ISMenuViewController = ISMenuViewController()
        
        URNavigationManager.addLeftButtonMenuInViewController(viewController)
        
        self.navigation = UINavigationController(rootViewController: viewController)
        URNavigationManager.setupNavigationDefaultAtrributes()
        self.navigation!.navigationBar.isTranslucent = true
        
        self.revealController = SWRevealViewController(rearViewController: menuViewController, frontViewController: self.navigation)
        self.revealController!.rearViewRevealWidth = 250
        self.revealController!.delegate = URNavigationManager.sharedInstance()
        
        viewController.view.isUserInteractionEnabled = true
        viewController.view.addGestureRecognizer(self.revealController!.panGestureRecognizer())
        
        URNavigationManager.switchRootViewController(self.revealController!, animated: true, completion: nil)
        appDelegate.window?.makeKeyAndVisible()
        
    }
    
    class func setFrontViewController(_ viewController:UIViewController){
        viewController.view.isUserInteractionEnabled = true
        viewController.view.addGestureRecognizer(self.revealController!.panGestureRecognizer())
        URNavigationManager.addLeftButtonMenuInViewController(viewController)
        self.navigation?.viewControllers = [viewController]
        self.revealController?.pushFrontViewController(self.navigation, animated: true)
    }
    
    class func setupNavigationControllerWithLoginViewController() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.navigation = UINavigationController(rootViewController: URLoginViewController())
        URNavigationManager.setupNavigationDefaultAtrributes()
        self.navigation!.navigationBar.isTranslucent = false
        self.navigation!.setNavigationBarHidden(true, animated: false)
        
        URNavigationManager.switchRootViewController(self.navigation!, animated: true, completion: nil)
        appDelegate.window?.makeKeyAndVisible()
    }
    
    class func setupNavigationControllerWithTutorialViewController() {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let tutorialViewController = URTutorialViewController()
        
        self.navigation = UINavigationController(rootViewController: tutorialViewController)
        URNavigationManager.setupNavigationDefaultAtrributes()
        self.navigation!.navigationBar.isTranslucent = false
        self.navigation!.setNavigationBarHidden(true, animated: false)
        
        URNavigationManager.switchRootViewController(self.navigation!, animated: true, completion: nil)
        appDelegate.window?.makeKeyAndVisible()
    }
    
    class func setupNavigationDefaultAtrributes() {
        self.navigation!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName:UIFont(name: "Avenir-Light", size: 20) as AnyObject
        ]
        
        self.navigation.navigationBar.tintColor = UIColor.white
        self.navigation.navigationBar.shadowImage = UIImage()
        self.navigation.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigation.navigationBar.isTranslucent = true
    }
    
    class func setupNavigationBarWithType(_ type:URNavigationBarType) {        
        switch type {
        case .clear:
            UIView.animate(withDuration: 0, animations: { () -> Void in
                self.navigation.navigationBar.shadowImage = UIImage()
                self.navigation.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            })
        break
        case .blue:
            UIView.animate(withDuration: 0, animations: { () -> Void in
                let defaultNavigationController = UINavigationController()
                self.navigation.navigationBar.barTintColor = URConstant.Color.PRIMARY
                self.navigation.navigationBar.shadowImage = defaultNavigationController.navigationBar.shadowImage
                self.navigation.navigationBar.setBackgroundImage(defaultNavigationController.navigationBar.backgroundImage(for: .default), for: .default)
            })
        break
        case .yellow:
            UIView.animate(withDuration: 0, animations: { () -> Void in
                let defaultNavigationController = UINavigationController()
                self.navigation.navigationBar.barTintColor = URConstant.Color.YELLOW
                self.navigation.navigationBar.shadowImage = defaultNavigationController.navigationBar.shadowImage
                self.navigation.navigationBar.setBackgroundImage(defaultNavigationController.navigationBar.backgroundImage(for: .default), for: .default)
            })
        break
            
        }
    }
    
    class func setupNavigationBarWithCustomColor(_ color:UIColor) {
        let defaultNavigationController = UINavigationController()
        self.navigation.navigationBar.barTintColor = color
        self.navigation.navigationBar.shadowImage = defaultNavigationController.navigationBar.shadowImage
        self.navigation.navigationBar.setBackgroundImage(defaultNavigationController.navigationBar.backgroundImage(for: .default), for: .default)
    }
    
    class func addLeftButtonMenuInViewController(_ viewController:UIViewController){
        let image:UIImage = ISImageUtil.resizeImage(UIImage(named: "icon_burgermenu")!,scaledToSize: CGSize(width: 20, height: 16))
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(toggleMenu))
    }
    
    class func toggleMenu() {
        self.revealController?.revealToggle(animated: true)
    }
    
    class func switchRootViewController(_ rootViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        
        if animated {
            UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
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
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            revealController.frontViewController.view.isUserInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            revealController.frontViewController.view.isUserInteractionEnabled = false
            revealController.frontViewController.revealViewController().tapGestureRecognizer().isEnabled = true
            revealController.frontViewController.revealViewController().panGestureRecognizer().isEnabled = true
            sidebarMenuOpen = true
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            // self.view.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            // self.view.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    
}
