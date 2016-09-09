//
//  URCoverView.swift
//  ureport
//
//  Created by Daniel Amaral on 14/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

protocol URMediaViewDelegate {
    func mediaViewTapped(mediaView:URMediaView)
    func removeMediaView(mediaView:URMediaView)
}

class URMediaView: UIView {
    
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var lbCover: UILabel!
    @IBOutlet weak var lbFileName: UILabel!
    @IBOutlet weak var lbDuration: UILabel!
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
            if !(self.media.type == URConstant.Media.AUDIO || self.media.type == URConstant.Media.FILE) {
                delegate.mediaViewTapped(self)
            }
        }
    }
    
    //MARK: Class Methods
    
    func setupWithMediaObject(media:URMedia) {
        
        self.media = media
        
        self.lbDuration.hidden = true
        
        if let media = media as? URVideoMedia {

            MBProgressHUD.showHUDAddedTo(self, animated: true)
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in

                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    MBProgressHUD.hideHUDForView(self, animated: true)
                    self.imgMedia.image = image
            })
            
            
        }else if let media = media as? URVideoPhoneMedia {
            
            self.imgMedia.image = media.thumbnailImage
            
        }else if let media = media as? URImageMedia {

            self.imgMedia.image = media.image
            
        }else if let media = media as? URLocalMedia {
            
            self.backgroundView.backgroundColor = URConstant.Color.MEDIA_FILE
            self.imgMedia.contentMode = UIViewContentMode.Center
            self.imgMedia.image = UIImage(named: "icon_file")
            self.lbFileName.text = media.metadata!["filename"] as? String
            
        }else if let media = media as? URAudioMedia {
            self.lbDuration.hidden = false
            self.backgroundView.backgroundColor = URConstant.Color.MEDIA_AUDIO
            self.imgMedia.contentMode = UIViewContentMode.Center
            self.imgMedia.image = UIImage(named: "ic_music_note_white")
            self.lbDuration.text = "\(media.metadata!["duration"]!)"
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
