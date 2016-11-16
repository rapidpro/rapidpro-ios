//
//  URBackendAuthManager.swift
//  ureport
//
//  Created by Daniel Amaral on 20/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

class URBackendAuthManager: NSObject {

    //MARK: FireBase Methods
    class func path() -> String {
        return "backend_authorization"
    }
    
    class func saveAuthToken(_ token:String,completion:@escaping (_ success:Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(byAppendingPath: URBackendAuthManager.path())
            .child(byAppendingPath: token)
            .setValue(["checked":true,"user":URUser.activeUser()!.key], withCompletionBlock: { (error:Error?, firebase: Firebase?) -> Void in
                if error != nil {
                    completion(false)
                }else {
                    completion(true)
                }
            })
    }
    
}
