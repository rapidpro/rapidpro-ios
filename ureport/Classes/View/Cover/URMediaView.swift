//
//  URCoverView.swift
//  ureport
//
//  Created by Daniel Amaral on 14/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

protocol URMediaViewDelegate {
    func mediaViewTapped(mediaView:URMediaView)
    func removeMediaView(mediaView:URMediaView)
}

class URMediaView: UIView {
    
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lbCover: UILabel!
    @IBOutlet weak var imgActive: UIImageView!
    
    var media:URMedia!
    var isCover:Bool!
    var delegate:URMediaViewDelegate?
    
    //MARK: Button Events
    
    @IBAction func btChoiceMediaTapped(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.mediaViewTapped(self)
        }
    }
    
    //MARK: Class Methods
    
    func setMediaAsCover(isCover:Bool) {
        self.isCover = isCover        
        if isCover {
            self.imgActive.image = UIImage(named:"icon_select_cover_active")
            self.viewBottom.hidden = false
        }else {
            self.imgActive.image = UIImage(named:"select_cover_inactive")
            self.viewBottom.hidden = true
        }
    }
    
    @IBAction func btDeleteTapped(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.removeMediaView(self)
        }
    }
}
