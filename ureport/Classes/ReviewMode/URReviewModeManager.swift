//
//  URReviewModeManager.swift
//  ureport
//
//  Created by Daniel Amaral on 15/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URReviewModeManager: NSObject {

    //MARK: FireBase Methods
    class func path() -> String {
        return "review"
    }
    
    class func checkIfIsInReviewMode(_ completion:@escaping (_ reviewMode:Bool) -> Void) {
        
        let settings = URSettings.getSettings()
        settings.reviewMode = false
        
        var version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        version = version.replacingOccurrences(of: ".", with: "")
        
//        URFireBaseManager.sharedInstance()
//            .childByAppendingPath(self.path())
//            .childByAppendingPath(version)
//            .setValue(["active":true], withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
//                
//            })
        
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: self.path())
            .child(byAppendingPath: version)
            .child(byAppendingPath: "active")
            .observeSingleEvent(of: .value, with: { snapshot in
                
                if let active = snapshot?.value as? Bool {
                    completion(active)
                }else{
                    completion(false)
                }
                
            })
    }
    
}
