//
//  URMediaImageView.swift
//  ureport
//
//  Created by Daniel Amaral on 18/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import SDWebImage

class URMediaImageView: UIView, NYTPhotosViewControllerDelegate {

    var photosViewController:NYTPhotosViewController!
    var media:URMedia!
    var viewController:UIViewController!
    var imageURL:String!
    var image:UIImage!
    
    @IBOutlet weak var imageView:UIImageView!
    
    //MARK: Button Events
    
    @IBAction func btImageViewTapped(button:UIButton) {
        
        let photoShow = PhotoShow(image: image, attributedCaptionTitle: NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]))
        
        photosViewController = NYTPhotosViewController(photos: [photoShow])
        photosViewController.delegate = self
        
        self.viewController.presentViewController(photosViewController, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        }
    }
    
    //MARK: Class Methods
    
    func setupWithMedia(media:URMedia,viewController:UIViewController) {
        self.imageURL = media.url
        self.imageView.sd_setImageWithURL(NSURL(string: self.imageURL), placeholderImage: nil) { (image:UIImage!, error:NSError!, SDImageCacheType, url:NSURL!) in
            self.image = image
        }
        self.media = media
        self.viewController = viewController
    }
    
    //MARK: NYTPhotosViewControllerDelegate
    
    func photosViewControllerDidDismiss(photosViewController: NYTPhotosViewController) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }

}
