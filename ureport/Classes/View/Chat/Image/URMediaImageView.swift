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
    
    @IBAction func btImageViewTapped(_ button:UIButton) {
        
        let photoShow = PhotoShow(image: image, attributedCaptionTitle: NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.white]))
        
        photosViewController = NYTPhotosViewController(photos: [photoShow])
        photosViewController.delegate = self
        
        self.viewController.present(photosViewController, animated: true) { () -> Void in
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
        }
    }
    
    //MARK: Class Methods
    
    func setupWithMedia(_ media:URMedia,viewController:UIViewController) {
        self.imageURL = media.url
        
        self.imageView.sd_setImage(with: URL(string: self.imageURL)) { (image, error, SDImageCacheType, url) in
            self.image = image
        }
        
        self.media = media
        self.viewController = viewController
    }
    
    //MARK: NYTPhotosViewControllerDelegate
    
    func photosViewControllerDidDismiss(_ photosViewController: NYTPhotosViewController) {
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }

}
