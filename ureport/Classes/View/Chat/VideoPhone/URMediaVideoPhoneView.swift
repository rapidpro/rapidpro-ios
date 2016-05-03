//
//  URMediaVideoPhoneView.swift
//  ureport
//
//  Created by Daniel Amaral on 17/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class URMediaVideoPhoneView: UIView {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var btPlay: UIButton!
    
    var viewController:UIViewController!
    var media:URMedia!
    
    //MARK: Button Events
    
    @IBAction func btPlayTapped(sender: AnyObject) {
        
        let url = NSURL(string: media.url)!
        
        let playerController = AVPlayerViewController()
        playerController.player = AVPlayer(URL: url)
        playerController.player!.play()
        
        self.viewController.presentViewController(playerController, animated: true, completion: nil)
    }
    
    //MARK: Class Methods
    
    func setupWithMedia(media:URMedia,andImageURL:String,viewController:UIViewController) {
        self.media = media
        self.viewController = viewController
        self.thumbnail.sd_setImageWithURL(NSURL(string: andImageURL))
    }
    
}
