//
//  URChatImageItem.swift
//  ureport
//
//  Created by Daniel Amaral on 18/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class URChatImageItem: JSQMediaItem {
    
    var imageURL:String!
    let mediaImageView = Bundle.main.loadNibNamed("URMediaImageView", owner: nil, options: nil)?[0] as! URMediaImageView
    var maskAsOutgoing:Bool!
    var viewController:UIViewController!
    var media:URMedia!
    var image:UIImage!
    
    override init() {
        super.init(maskAsOutgoing:true)
    }
    
    init(media:URMedia,viewController:UIViewController,maskAsOutgoing:Bool) {
        self.imageURL = media.url
        self.media = media
        self.viewController = viewController
        self.maskAsOutgoing = maskAsOutgoing
        super.init(maskAsOutgoing:maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func mediaView() -> UIView! {
        if mediaImageView.media == nil {
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: self.mediaImageView, isOutgoing: self.maskAsOutgoing)
            self.mediaImageView.setupWithMedia(self.media, viewController: self.viewController)
        }
        return mediaImageView
    }
    
    @objc override func mediaViewDisplaySize() -> CGSize {
        return mediaImageView.frame.size
    }
    
    @objc override func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
//    @objc override func mediaHash() -> UInt {
//        return UInt(self.hash)
//    }
    
}
