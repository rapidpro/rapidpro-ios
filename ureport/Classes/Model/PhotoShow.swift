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
    let attributedCaptionTitle: NSAttributedString
    let attributedCaptionSummary = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
    let attributedCaptionCredit = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    
    init(image: UIImage?, attributedCaptionTitle: NSAttributedString) {
        self.image = image
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }
    
    convenience init(attributedCaptionTitle: NSAttributedString) {
        self.init(image: nil, attributedCaptionTitle: attributedCaptionTitle)
    }
    
}
