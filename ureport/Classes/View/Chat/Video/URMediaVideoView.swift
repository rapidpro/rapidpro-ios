//
//  URMediaVideoView.swift
//  ureport
//
//  Created by Daniel Amaral on 12/04/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class URMediaVideoView: UIView {

    var media:URMedia!
    
    //MARK: Class Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithMedia(media:URMedia) {
        self.media = media
        
        let frame = CGRect(x: 0, y: 0, width: 230, height: 230)
        let playerView = YTPlayerView(frame: frame)
        
        self.addSubview(playerView)
        playerView.loadWithVideoId(media.id)
        
    }
}
