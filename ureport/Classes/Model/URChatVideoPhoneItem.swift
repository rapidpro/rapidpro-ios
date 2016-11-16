//
//  URChatImageItem.swift
//  ureport
//
//  Created by Daniel Amaral on 18/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class URChatVideoPhoneItem: JSQMediaItem {
    
    var imageURL:String!
    let mediaVideoPhoneView = Bundle.main.loadNibNamed("URMediaVideoPhoneView", owner: nil, options: nil)?[0] as! URMediaVideoPhoneView
    var maskAsOutgoing:Bool!
    var media:URMedia!
    var viewController:UIViewController!
    
    override init() {
        super.init(maskAsOutgoing:true)
    }
    
    init(media:URMedia,maskAsOutgoing:Bool,viewController:UIViewController) {
        self.viewController = viewController
        self.imageURL = media.thumbnail
        self.media = media
        self.maskAsOutgoing = maskAsOutgoing
        super.init(maskAsOutgoing:maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func mediaView() -> UIView! {
        if mediaVideoPhoneView.media == nil {
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: mediaVideoPhoneView, isOutgoing: maskAsOutgoing)
            mediaVideoPhoneView.setupWithMedia(media,andImageURL: imageURL, viewController: viewController)
        }
        return mediaVideoPhoneView
    }
    
    @objc override func mediaViewDisplaySize() -> CGSize {
        return mediaVideoPhoneView.frame.size
    }
    
    @objc override func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
//    @objc override func mediaHash() -> UInt {
//        return UInt(self.hash)
//    }
    
}
