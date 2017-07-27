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
    func playMediaViewDidTap(_ playMediaView:URPlayMediaView)
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
    
    class func buildImageView(_ image:UIImage) -> UIImageView {
        let imgView = UIImageView(image: image)
        imgView.frame = URPlayMediaView.defaultFrame
        imgView.layer.borderWidth = 2
        imgView.layer.borderColor = UIColor.white.cgColor
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        imgView.isUserInteractionEnabled = true
        return imgView
    }
    
    func setupViewWithMedia(_ viewController:UIViewController,media:URMedia) {
        
        self.parentViewController = viewController
        self.media = media
        self.frame = URPlayMediaView.defaultFrame
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMedia))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        
        if media.type == URConstant.Media.PICTURE {
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:media.url), options: SDWebImageDownloaderOptions.highPriority, progress: { (_, _, _) in }, completed: { (image, data, error, finished) in
                if let image = image {
                    self.addSubview(URPlayMediaView.buildImageView(image))
                } else {
                    print("error on image download")
                }
            })
        }else if media.type == URConstant.Media.VIDEO {
            
            let youtubePlayerView = YTPlayerView(frame: URPlayMediaView.defaultFrame)
            youtubePlayerView.load(withVideoId: media.id!)
            youtubePlayerView.layer.borderWidth = 2
            youtubePlayerView.layer.borderColor = UIColor.white.cgColor
            
            self.addSubview(youtubePlayerView)

        }else if media.type == URConstant.Media.VIDEOPHONE {
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:media.thumbnail!), options: SDWebImageDownloaderOptions.highPriority, progress: { (_, _, _) in }, completed: { (image, data, error, finished) in
                if let image = image {
                    self.addSubview(URPlayMediaView.buildImageView(image))
                    let playImage = UIImageView(image: UIImage(named: "ic_play_48"))
                    playImage.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
                    self.addSubview(playImage)
                } else {
                    print("error in image download")
                }
            })
        }else if media.type == URConstant.Media.FILE {
            let backgroundView = UIView(frame: URPlayMediaView.defaultFrame)
            backgroundView.backgroundColor = URConstant.Color.MEDIA_FILE
            
            let fileIconImgView = UIImageView(image: UIImage(named: "icon_file"))
            fileIconImgView.contentMode = UIViewContentMode.center
            fileIconImgView.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
            backgroundView.addSubview(fileIconImgView)
            backgroundView.layer.borderWidth = 2
            backgroundView.layer.borderColor = UIColor.white.cgColor
            
            self.addSubview(backgroundView)
            
        }else if media.type == URConstant.Media.AUDIO {

            let backgroundView = UIView(frame: URPlayMediaView.defaultFrame)
            backgroundView.backgroundColor = URConstant.Color.MEDIA_AUDIO
            
            let audioIconImgView = UIImageView(image: UIImage(named: "ic_music_note_white"))
            audioIconImgView.contentMode = UIViewContentMode.center
            audioIconImgView.frame = CGRect(x: (URPlayMediaView.defaultFrame.width - 30) / 2, y: (URPlayMediaView.defaultFrame.height - 30) / 2, width: 30, height: 30)
            backgroundView.addSubview(audioIconImgView)
            
            let lbDuration = UILabel(frame: CGRect(x: 2, y: 75, width: 20, height: 30))
            lbDuration.textAlignment = NSTextAlignment.left
            lbDuration.adjustsFontSizeToFitWidth = true
            lbDuration.font = lbDuration.font.withSize(12)
            lbDuration.textColor = UIColor.white
            
            if media.metadata != nil && media.metadata!["duration"] != nil {
                print("\(String(describing: media.metadata!["duration"]))")
                lbDuration.text = "\(media.metadata!["duration"]!)"
            }
            
            backgroundView.addSubview(lbDuration)
            backgroundView.layer.borderWidth = 2
            backgroundView.layer.borderColor = UIColor.white.cgColor
            
            self.addSubview(backgroundView)
            
        }
        
    }
    
    func openMedia(_ tapGesture:UITapGestureRecognizer) {
        
        let playMediaView = tapGesture.view as! URPlayMediaView
        
        let media = playMediaView.media
        
        if media?.type == URConstant.Media.PICTURE {

            let image = (playMediaView.subviews[0] as! UIImageView).image
            
            let title = NSAttributedString(string: "Photo", attributes: [NSForegroundColorAttributeName: UIColor.white])
            let photo = PhotoShow(image: image, attributedCaptionTitle: title)
            
            let photosViewController = NYTPhotosViewController(photos: [photo])
            photosViewController.delegate = self
            
            self.parentViewController.present(photosViewController, animated: true) { () -> Void in
                UIApplication.shared.setStatusBarHidden(true, with: .fade)
            }
            
        }else if media?.type == URConstant.Media.VIDEO {
            
            
        }else if media?.type == URConstant.Media.VIDEOPHONE {
            
            let url = URL(string: (media?.url)!)!
            
            let playerController = AVPlayerViewController()
            playerController.player = AVPlayer(url: url)
            playerController.player!.play()
            
            self.parentViewController.present(playerController, animated: true, completion: nil)
            
        }else if media?.type == URConstant.Media.FILE {
            
            if let checkURL = URL(string: (media?.url)!) {
                if UIApplication.shared.openURL(checkURL) {
                    print("url successfully opened")
                }
            } else {
                print("invalid url")
            }
            
        }else if media?.type == URConstant.Media.AUDIO {
            
            let audioRecorderViewController = URAudioRecorderViewController(audioURL: media?.url)
            
            audioRecorderViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            URNavigationManager.navigation.present(audioRecorderViewController, animated: true) { () -> Void in
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    audioRecorderViewController.view.backgroundColor  = UIColor.black.withAlphaComponent(0.5)
                }) 
            }
            
        }
        
    }
    
    //MARK: PhotosViewControllerDelegate
    
    func photosViewControllerDidDismiss(_ photosViewController: NYTPhotosViewController) {
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
}
