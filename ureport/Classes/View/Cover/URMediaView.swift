//
//  URCoverView.swift
//  ureport
//
//  Created by Daniel Amaral on 14/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import SDWebImage

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
    var type:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lbCover.text = "cover_title".localized
    }
    
    //MARK: Button Events
    
    @IBAction func btChoiceMediaTapped(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.mediaViewTapped(self)
        }
    }
    
    //MARK: Class Methods
    
    func setupWithMediaObject(media:URMedia) {
        
        self.media = media
        
        if let media = media as? URVideoMedia {

            ProgressHUD.show(nil)
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in

                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    ProgressHUD.dismiss()
                    self.imgMedia.image = image
            })
            
            
        }else if let media = media as? URVideoPhoneMedia {
            
            self.imgMedia.image = media.thumbnailImage
            
        }else if let media = media as? URImageMedia {

            self.imgMedia.image = media.image
            
        }else if let media = media as? URLocalMedia {
            
            
        }
        
    }
    
    func setMediaAsCover(isCover:Bool) {
        self.isCover = isCover        
        if isCover {
            self.media.isCover = true
            self.imgActive.image = UIImage(named:"icon_select_cover_active")
            self.viewBottom.hidden = false
        }else {
            self.media.isCover = false
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
