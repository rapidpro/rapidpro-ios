//
//  URChatImageItem.swift
//  ureport
//
//  Created by Daniel Amaral on 18/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class URChatFileItem: JSQMediaItem {
    
    let mediaFileView = Bundle.main.loadNibNamed("URMediaFileView", owner: nil, options: nil)?[0] as! URMediaFileView
    var maskAsOutgoing:Bool!
    var media:URMedia!
    
    override init(maskAsOutgoing:Bool) {
        super.init(maskAsOutgoing:true)
    }    
    
    init(media:URMedia,maskAsOutgoing:Bool) {
        self.media = media
        
        self.maskAsOutgoing = maskAsOutgoing
        super.init(maskAsOutgoing:maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func mediaView() -> UIView! {
        if mediaFileView.media == nil {
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: mediaFileView, isOutgoing: maskAsOutgoing)
            mediaFileView.setupWithMedia(media)
        }
        return mediaFileView
    }
    
    @objc override func mediaViewDisplaySize() -> CGSize {
        return mediaFileView.frame.size
    }
    
    @objc override func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
//    @objc override func mediaHash() -> UInt {
//        return UInt(self.hash)
//    }
    
    
}
