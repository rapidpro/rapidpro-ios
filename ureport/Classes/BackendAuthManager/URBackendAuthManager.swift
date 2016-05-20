//
//  URBackendAuthManager.swift
//  ureport
//
//  Created by Daniel Amaral on 20/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URBackendAuthManager: NSObject {

    //MARK: FireBase Methods
    class func path() -> String {
        return "backend_authorization"
    }
    
    class func saveAuthToken(token:String,completion:(success:Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .childByAppendingPath(URBackendAuthManager.path())
            .childByAppendingPath(token)
            .setValue(["checked":true,"user":URUser.activeUser()!.key], withCompletionBlock: { (error:NSError!, firebase: Firebase!) -> Void in
                if error != nil {
                    completion(success: false)
                }else {
                    completion(success: true)
                }
            })
    }
    
}
