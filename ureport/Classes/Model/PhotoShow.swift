//
//  PhotoShow.swift
//  ureport
//
//  Created by Daniel Amaral on 18/09/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class PhotoShow: NSObject, NYTPhoto {

    var index:Int!
    var image: UIImage?
    var placeholderImage: UIImage?
    var imageData:Data?
    let attributedCaptionTitle: NSAttributedString?
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.gray])
    let attributedCaptionCredit:  NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
    
    init(image: UIImage? = nil, imageData: Data? = nil, attributedCaptionTitle: NSAttributedString) {
        self.image = image
        self.attributedCaptionTitle = attributedCaptionTitle
        super.init()
    }
    
}
