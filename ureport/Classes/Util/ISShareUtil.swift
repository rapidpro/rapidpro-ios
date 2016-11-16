//
//  ISShareUtil.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 07/08/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class ISShareUtil: NSObject {
   
    class func share(_ viewController:UIViewController,objects:[AnyObject]) {
        
        let vc = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        /* If you want to exclude certain types from sharing
        options you could add them to the excludedActivityTypes */
        //        vc.excludedActivityTypes = [UIActivityTypeMail]
        viewController.present(vc, animated: true, completion: nil)
        
    }
    
    
}
