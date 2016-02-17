//
//  URPlayMediaView.swift
//  ureport
//
//  Created by Daniel Amaral on 15/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import SDWebImage
import MediaPlayer
import youtube_ios_player_helper
import NYTPhotoViewer

protocol URPlayMediaViewDelegate {
    func playMediaViewDidTap(playMediaView:URPlayMediaView)
}

class URPlayMediaView: UIView {

    static let defaultFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    init(parentViewController:UIViewController, media:URMedia) {
        super.init(frame: URPlayMediaView.defaultFrame)
        setupViewWithMedia(parentViewController, media: media)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView:UIImageView!
    var media:URMedia!
    var delegate:URPlayMediaViewDelegate?
    var parentViewController:UIViewController!
    
    class func buildImageView(image:UIImage) -> UIImageView {
        let imgView = UIImageView(image: image)
        imgView.frame = URPlayMediaView.defaultFrame
        imgView.layer.borderWidth = 2
        imgView.layer.borderColor = UIColor.whiteColor().CGColor
        imgView.contentMode = UIViewContentMode.ScaleAspectFill
        imgView.userInteractionEnabled = true
        return imgView
    }
    
    func setupViewWithMedia(viewController:UIViewController,media:URMedia) {
        
        self.parentViewController = viewController
        self.media = media
        self.frame = URPlayMediaView.defaultFrame
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "openMedia:")
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        
        if media.type == URConstant.Media.PICTURE {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    self.addSubview(URPlayMediaView.buildImageView(image))
            })
            
        }else if media.type == URConstant.Media.VIDEO {
            
            let youtubePlayerView = YTPlayerView(frame: URPlayMediaView.defaultFrame)
            youtubePlayerView.loadWithVideoId(media.id)
            self.addSubview(youtubePlayerView)
            
        }else if media.type == URConstant.Media.VIDEOPHONE {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.thumbnail), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    self.addSubview(URPlayMediaView.buildImageView(image))
                    
            })
        }else if media.type == URConstant.Media.FILE {
            let backgroundView = UIView(frame: URPlayMediaView.defaultFrame)
            backgroundView.backgroundColor = UIColor.orangeColor()
            
            let fileIconImgView = UIImageView(image: UIImage(named: "icon_file"))
            fileIconImgView.contentMode = UIViewContentMode.Center
            fileIconImgView.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
            backgroundView.addSubview(fileIconImgView)
            self.addSubview(backgroundView)
            
        }
        
    }
    
    func openMedia(tapGesture:UITapGestureRecognizer) {
        
        let playMediaView = tapGesture.view as! URPlayMediaView
        
        let media = playMediaView.media
        
        if media.type == URConstant.Media.PICTURE {

            let image = (playMediaView.subviews[0] as! UIImageView).image
            
            let title = NSAttributedString(string: "Photo", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            let photo = PhotoShow(image: image, attributedCaptionTitle: title)
            
            let photosViewController = NYTPhotosViewController(photos: [photo])
            
            self.parentViewController.presentViewController(photosViewController, animated: true) { () -> Void in
            }
            
        }else if media.type == URConstant.Media.VIDEO {
            
            
        }else if media.type == URConstant.Media.VIDEOPHONE {
            
            let url = NSURL(string: media.url)!

            let moviePlayer = MPMoviePlayerViewController(contentURL: url)

            moviePlayer.moviePlayer.controlStyle = .Embedded
            moviePlayer.moviePlayer.prepareToPlay()
            moviePlayer.moviePlayer.play()
            moviePlayer.moviePlayer.setFullscreen(true, animated: true)

            self.parentViewController.presentMoviePlayerViewControllerAnimated(moviePlayer)
            
        }else if media.type == URConstant.Media.FILE {
            
            if let checkURL = NSURL(string: media.url) {
                if UIApplication.sharedApplication().openURL(checkURL) {
                    print("url successfully opened")
                }
            } else {
                print("invalid url")
            }
            
        }
        
    }
    
}
