//
//  URBackendAuthManager.swift
//  ureport
//
//  Created by Daniel Amaral on 20/05/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import Firebase

class URBackendAuthManager {

    //MARK: FireBase Methods
    class func path() -> String {
        return "backend_authorization"
    }
    
    class func saveAuthToken(_ token:String,completion:@escaping (_ success:Bool) -> Void) {
        URFireBaseManager.sharedInstance()
            .child(URBackendAuthManager.path())
            .child(token)
            .setValue(["checked": true, "user": URUser.activeUser()!.key]) { (error, _) -> Void in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
}
