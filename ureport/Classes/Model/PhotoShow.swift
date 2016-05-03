//
//  PhotoShow.swift
//  ureport
//
//  Created by Daniel Amaral on 18/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class PhotoShow: NSObject, NYTPhoto{

    var index:Int!
    var image: UIImage?
    var placeholderImage: UIImage?
    var imageData:NSData?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
    let attributedCaptionCredit:  NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    
    init(image: UIImage? = nil, imageData: NSData? = nil, attributedCaptionTitle: NSAttributedString) {
        self.image = image
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }
    
}
