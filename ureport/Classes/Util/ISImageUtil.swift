//
//  ISImageUtil.swift
//  TimeDePrimeira
//
//  Created by Daniel Amaral on 29/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

class ISImageUtil: NSObject {
   
    static func resizeImage(image:UIImage, scaledToSize: CGSize) -> UIImage{
     UIGraphicsBeginImageContextWithOptions(scaledToSize, false, 0.0)
        image.drawInRect(CGRect(x: 0, y: 0, width: scaledToSize.width, height: scaledToSize.height))
        let newImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
