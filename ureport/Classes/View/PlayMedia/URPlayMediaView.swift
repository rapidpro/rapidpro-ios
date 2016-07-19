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
import AVFoundation
import AVKit

protocol URPlayMediaViewDelegate {
    func playMediaViewDidTap(playMediaView:URPlayMediaView)
}

class URPlayMediaView: UIView, NYTPhotosViewControllerDelegate {

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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMedia))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        
        if media.type == URConstant.Media.PICTURE {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.url), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    if let image = image {
                        self.addSubview(URPlayMediaView.buildImageView(image))
                    }else{
                        print("error on image download")
                    }
            })
            
        }else if media.type == URConstant.Media.VIDEO {
            
            let youtubePlayerView = YTPlayerView(frame: URPlayMediaView.defaultFrame)
            youtubePlayerView.loadWithVideoId(media.id)
            youtubePlayerView.layer.borderWidth = 2
            youtubePlayerView.layer.borderColor = UIColor.whiteColor().CGColor
            
            self.addSubview(youtubePlayerView)

        }else if media.type == URConstant.Media.VIDEOPHONE {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string:media.thumbnail), options: SDWebImageOptions.AvoidAutoSetImage, progress: { (receivedSize, expectedSize) -> Void in
                
                }, completed: { (image, error, cacheType, finish, url) -> Void in
                    
                    if let image = image {
                        self.addSubview(URPlayMediaView.buildImageView(image))
                        let playImage = UIImageView(image: UIImage(named: "ic_play_48"))
                        playImage.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
                        self.addSubview(playImage)
                    }else{
                        print("error on image download")
                    }
                    
            })
        }else if media.type == URConstant.Media.FILE {
            let backgroundView = UIView(frame: URPlayMediaView.defaultFrame)
            backgroundView.backgroundColor = URConstant.Color.MEDIA_FILE
            
            let fileIconImgView = UIImageView(image: UIImage(named: "icon_file"))
            fileIconImgView.contentMode = UIViewContentMode.Center
            fileIconImgView.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
            backgroundView.addSubview(fileIconImgView)
            backgroundView.layer.borderWidth = 2
            backgroundView.layer.borderColor = UIColor.whiteColor().CGColor
            
            self.addSubview(backgroundView)
            
        }else if media.type == URConstant.Media.AUDIO {

            let backgroundView = UIView(frame: URPlayMediaView.defaultFrame)
            backgroundView.backgroundColor = URConstant.Color.MEDIA_AUDIO
            
            let audioIconImgView = UIImageView(image: UIImage(named: "ic_music_note_white"))
            audioIconImgView.contentMode = UIViewContentMode.Center
            audioIconImgView.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
            backgroundView.addSubview(audioIconImgView)
            
            let lbDuration = UILabel(frame: CGRect(x: 2, y: 75, width: 20, height: 30))
            lbDuration.textAlignment = NSTextAlignment.Left
            lbDuration.adjustsFontSizeToFitWidth = true
            lbDuration.font = lbDuration.font.fontWithSize(12)
            lbDuration.textColor = UIColor.whiteColor()
            
            if media.metadata != nil && media.metadata!["duration"] != nil {
                print("\(media.metadata!["duration"])")
                lbDuration.text = "\(media.metadata!["duration"]!)"
            }
            
            backgroundView.addSubview(lbDuration)
            backgroundView.layer.borderWidth = 2
            backgroundView.layer.borderColor = UIColor.whiteColor().CGColor
            
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
            photosViewController.delegate = self
            
            self.parentViewController.presentViewController(photosViewController, animated: true) { () -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
            }
            
        }else if media.type == URConstant.Media.VIDEO {
            
            
        }else if media.type == URConstant.Media.VIDEOPHONE {
            
            let url = NSURL(string: media.url)!
            
            let playerController = AVPlayerViewController()
            playerController.player = AVPlayer(URL: url)
            playerController.player!.play()
            
            self.parentViewController.presentViewController(playerController, animated: true, completion: nil)
            
        }else if media.type == URConstant.Media.FILE {
            
            if let checkURL = NSURL(string: media.url) {
                if UIApplication.sharedApplication().openURL(checkURL) {
                    print("url successfully opened")
                }
            } else {
                print("invalid url")
            }
            
        }else if media.type == URConstant.Media.AUDIO {
            
            let audioRecorderViewController = URAudioRecorderViewController(audioURL: media.url)
            
            audioRecorderViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            URNavigationManager.navigation.presentViewController(audioRecorderViewController, animated: true) { () -> Void in
                UIView.animateWithDuration(0.3) { () -> Void in
                    audioRecorderViewController.view.backgroundColor  = UIColor.blackColor().colorWithAlphaComponent(0.5)
                }
            }
            
        }
        
    }
    
    //MARK: PhotosViewControllerDelegate
    
    func photosViewControllerDidDismiss(photosViewController: NYTPhotosViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }
    
}
