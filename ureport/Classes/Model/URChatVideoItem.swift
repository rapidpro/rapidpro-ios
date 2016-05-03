//
//  URChatImageItem.swift
//  ureport
//
//  Created by Daniel Amaral on 18/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class URChatVideoItem: JSQMediaItem {
    
    let mediaVideoView = URMediaVideoView(frame: CGRect(x: 0, y: 0, width: 230, height: 230))
    var maskAsOutgoing:Bool!
    var media:URMedia!
    
    override init(maskAsOutgoing:Bool) {
        self.maskAsOutgoing = maskAsOutgoing
        super.init(maskAsOutgoing:maskAsOutgoing)
    }    
    
    init(media:URMedia,maskAsOutgoing:Bool) {
        super.init()
        self.maskAsOutgoing = maskAsOutgoing
        self.media = media
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func mediaView() -> UIView! {
        if mediaVideoView.media == nil {
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(mediaVideoView, isOutgoing: maskAsOutgoing)
            mediaVideoView.setupWithMedia(media)
        }
        return mediaVideoView
    }
    
    @objc override func mediaViewDisplaySize() -> CGSize {
        return mediaVideoView.frame.size
    }
    
    @objc override func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
    @objc override func mediaHash() -> UInt {
        return UInt(self.hash)
    }
    
}
