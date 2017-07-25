//
//  URReviewModeManager.swift
//  ureport
//
//  Created by Daniel Amaral on 15/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URReviewModeManager {

    //MARK: FireBase Methods
    class func path() -> String {
        return "review"
    }

    class func checkIfIsInReviewMode(_ completion:@escaping (_ reviewMode:Bool) -> Void) {

        let settings = URSettings.getSettings()
        settings.reviewMode = false

        var version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        version = version.replacingOccurrences(of: ".", with: "")

        URFireBaseManager.sharedInstance()
            .child(self.path())
            .child(version)
            .child("active")
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let active = snapshot.value as? Bool else {
                    completion(false)
                    return
                }
                completion(active)
            })
    }
    
}
