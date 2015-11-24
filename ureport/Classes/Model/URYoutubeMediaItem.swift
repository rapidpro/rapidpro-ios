//
//  URYoutubeMediaItem.swift
//  ureport
//
//  Created by Daniel Amaral on 23/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class URYoutubeMediaItem: JSQMediaItem {

    var media:URMedia!
    
    init(media:URMedia) {
        self.media = media
        super.init(maskAsOutgoing: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        return self.mediaView()
    }
    
    override func mediaPlaceholderView() -> UIView! {
        return self.mediaPlaceholderView()
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return self.mediaViewDisplaySize()
    }
    
    override func mediaHash() -> UInt {
        return self.mediaHash()
    }
    
}
