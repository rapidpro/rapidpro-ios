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
    func mediaViewTapped(_ mediaView:URMediaView)
    func removeMediaView(_ mediaView:URMediaView)
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
    
    @IBAction func btChoiceMediaTapped(_ sender: AnyObject) {
        if let delegate = self.delegate {
            if !(self.media.type == URConstant.Media.AUDIO || self.media.type == URConstant.Media.FILE) {
                delegate.mediaViewTapped(self)
            }
        }
    }
    
    //MARK: Class Methods
    
    func setupWithMediaObject(_ media:URMedia) {
        
        self.media = media
        
        self.lbDuration.isHidden = true
        
        if let media = media as? URVideoMedia {
            MBProgressHUD.showAdded(to: self, animated: true)
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:media.url), options: SDWebImageDownloaderOptions.highPriority, progress: { (_, _, _) in }, completed: { (image, data, error, finished) in
                MBProgressHUD.hide(for: self, animated: true)
                self.imgMedia.image = image
            })
        }else if let media = media as? URVideoPhoneMedia {
            
            self.imgMedia.image = media.thumbnailImage
            
        }else if let media = media as? URImageMedia {

            self.imgMedia.image = media.image
            
        }else if let media = media as? URLocalMedia {
            
            self.backgroundView.backgroundColor = URConstant.Color.MEDIA_FILE
            self.imgMedia.contentMode = UIViewContentMode.center
            self.imgMedia.image = UIImage(named: "icon_file")
            self.lbFileName.text = media.metadata!["filename"] as? String
            
        }else if let media = media as? URAudioMedia {
            self.lbDuration.isHidden = false
            self.backgroundView.backgroundColor = URConstant.Color.MEDIA_AUDIO
            self.imgMedia.contentMode = UIViewContentMode.center
            self.imgMedia.image = UIImage(named: "ic_music_note_white")
            self.lbDuration.text = "\(media.metadata!["duration"]!)"
        }
        
    }
    
    func setMediaAsCover(_ isCover:Bool) {
        self.isCover = isCover        
        if isCover {
            self.media.isCover = true
            self.imgActive.image = UIImage(named:"icon_select_cover_active")
            self.viewBottom.isHidden = false
        }else {
            self.media.isCover = false
            self.imgActive.image = UIImage(named:"select_cover_inactive")
            self.viewBottom.isHidden = true
        }
    }
    
    @IBAction func btDeleteTapped(_ sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.removeMediaView(self)
        }
    }
}
