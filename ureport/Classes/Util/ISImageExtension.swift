//
//  ISImageExtension.swift
//  ureport
//
//  Created by Daniel Amaral on 16/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

extension UIImage {

    convenience init(color: UIColor, size: CGSize = CGSizeMake(1, 1)) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }

}
