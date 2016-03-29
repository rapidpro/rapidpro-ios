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
    
    class func checkIfIsInReviewMode(completion:(reviewMode:Bool) -> Void) {
        
        var version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        version = version.stringByReplacingOccurrencesOfString(".", withString: "")
        
//        URFireBaseManager.sharedInstance()
//            .childByAppendingPath(self.path())
//            .childByAppendingPath(version)
//            .setValue(["active":true], withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
//                
//            })
        
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(self.path())
            .childByAppendingPath(version)
            .childByAppendingPath("active")
            .observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
                
                if let active = snapshot.value as? Bool {
                    completion(reviewMode: active)
                }else{
                    completion(reviewMode: false)
                }
                
            })
    }
    
}
