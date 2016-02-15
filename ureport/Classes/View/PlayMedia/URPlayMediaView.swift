//
//  URPlayMediaView.swift
//  ureport
//
//  Created by Daniel Amaral on 15/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import SDWebImage

class URPlayMediaView: UIView {

    static let defaultFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    var imageView:UIImageView! {
        let imgView = UIImageView()
        imgView.frame = URPlayMediaView.defaultFrame
        imgView.layer.borderWidth = 2
        imgView.layer.borderColor = UIColor.whiteColor().CGColor
        imgView.contentMode = UIViewContentMode.ScaleAspectFill
        imgView.userInteractionEnabled = true
        return imgView
    }
    
    var media:URMedia!
    
    func setupViewWithMedia(media:URMedia) {
        
        self.media = media
        self.frame = URPlayMediaView.defaultFrame
        
        if media.type == URConstant.Media.PICTURE {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    self.imageView.image = image
                    self.addSubview(self.imageView)
            })
            
        }else if media.type == URConstant.Media.VIDEO {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    self.imageView.image = image
                    self.addSubview(self.imageView)
            })
            
        }else if media.type == URConstant.Media.VIDEOPHONE {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.thumbnail), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    self.imageView.image = image
                    self.addSubview(self.imageView)                    
            })
        }
        
    }
    
}
