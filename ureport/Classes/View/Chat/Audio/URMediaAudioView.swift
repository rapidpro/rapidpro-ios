//
//  URMediaAudioView.swift
//  ureport
//
//  Created by Daniel Amaral on 16/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation

class URMediaAudioView: UIView, URAudioViewDelegate {

    @IBOutlet weak var bgAudioView:UIView!
    var media:URMedia!
    
    let audioView = Bundle.main.loadNibNamed("URAudioView", owner: nil, options: nil)?[0] as! URAudioView
    
    override func awakeFromNib() {
        super.awakeFromNib()

        audioView.audioViewdelegate = self
        
        var frame = audioView.frame
        frame.size.width = self.bgAudioView.frame.size.width
        audioView.frame = frame
        bgAudioView.addSubview(audioView)
        bgAudioView.layoutSubviews()
    }
    
    func setupWithMedia(_ media:URMedia) {
        self.media = media
                
        audioView.playAudioImmediately(media.url,showPreloading: false)
    }
    
    //MARK: URAudioViewDelegate
 
    func finishRecord() {
        
    }
    
    func didStartPlaying(_ view: URAudioView) {
        if view != audioView {
            view.play()
        }
    }
}
