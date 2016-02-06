//
//  URMediaUpload.swift
//  ureport
//
//  Created by Daniel Amaral on 05/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URMediaUpload: NSObject {

    class func uploadMedias(medias:[URMedia],completion:(medias:[URMedia]) -> Void) {
        
        let mediaList:[URMedia] = []
        
        for media in medias {
            
            if let media = media as? URVideoMedia {
                
            }else if let media = media as? URVideoPhoneMedia {
                
                
            }else if let media = media as? URImageMedia {
                
                
            }else if let media = media as? URLocalMedia {

                
            }
            
        }
     
        completion(medias: mediaList)
        
    }
    
}
