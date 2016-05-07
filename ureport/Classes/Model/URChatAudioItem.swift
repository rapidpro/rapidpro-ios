//
//  URChatImageItem.swift
//  ureport
//
//  Created by Daniel Amaral on 18/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation

class URChatAudioItem: JSQMediaItem {
    
    let mediaAudioView = NSBundle.mainBundle().loadNibNamed("URMediaAudioView", owner: nil, options: nil)[0] as! URMediaAudioView
    var maskAsOutgoing:Bool!
    var media:URMedia!
    
    override init() {
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
        if mediaAudioView.media == nil {
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(mediaAudioView, isOutgoing: maskAsOutgoing)        
            mediaAudioView.setupWithMedia(media)
        }
        return mediaAudioView
    }
    
    @objc override func mediaViewDisplaySize() -> CGSize {
        return mediaAudioView.frame.size
    }
    
    @objc override func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
//    @objc override func mediaHash() -> UInt {
//        return UInt(self.hash)
//    }
    
}
