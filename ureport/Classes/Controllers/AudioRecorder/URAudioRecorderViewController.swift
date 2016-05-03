//
//  URAudioRecorderViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 17/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation

protocol URAudioRecorderViewControllerDelegate {
    func newAudioRecorded(audioRecorderViewController:URAudioRecorderViewController,media:URMedia)
}

class URAudioRecorderViewController: UIViewController, URAudioRecorderManagerDelegate, AVAudioPlayerDelegate, URAudioViewDelegate {

    @IBOutlet weak var lbRecorder: UILabel!
    @IBOutlet weak var btRecording: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var bgAudioView: UIView!
    
    var delegate:URAudioRecorderViewControllerDelegate?
    
    let audioView = NSBundle.mainBundle().loadNibNamed("URAudioView", owner: nil, options: nil)[0] as! URAudioView
    let maximumTime = 50
    
    var audioMedia:URAudioMedia?
    
    init(audioURL:String?) {
        super.init(nibName: "URAudioRecorderViewController", bundle: nil)
        audioView.isRecording = false
        audioView.audioRemoteURL = audioURL
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        
        audioView.audioViewdelegate = self
        
        if let audioRemoteURL = audioView.audioRemoteURL {
            audioView.playAudioImmediately(audioRemoteURL,showPreloading: true)
        }else{
            self.btRecording.hidden = false
            audioView.btPlay.enabled = false
            audioView.setupSlider()
            audioView.lbMaxTime.text = audioView.getDurationString(maximumTime)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = audioView.frame
        frame.size.width = self.bgAudioView.frame.size.width
        audioView.frame = frame
        
        bgAudioView.addSubview(audioView)
        bgAudioView.layoutSubviews()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        audioMedia = nil

        if audioView.player != nil && audioView.player.playing == true {
            audioView.player.stop()
        }

    }
    
    //MARK: Button Events
    
    @IBAction func btPlayTapped() {
        audioView.play()
    }
    
    @IBAction func btCancelTapped() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.colorWithAlphaComponent(0)
            }) { (finished) -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("modalProfileDidClosed", object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func btRecordTapped() {
        
        if let audioMedia = audioMedia {
            if let delegate = delegate {
                audioMedia.metadata = ["duration":Int(audioView.player.duration)]
                delegate.newAudioRecorded(self, media: audioMedia)
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }
        }
        
        if audioView.isRecording == true {
            audioView.needFinishRecord()
        }else{
            audioView.isRecording = true
            audioView.audioRecorder = URAudioRecorderManager()
            audioView.audioRecorder.delegate = self
            self.btRecording.setTitle("Stop", forState: UIControlState.Normal)
            audioView.startTimeRecording = CFAbsoluteTimeGetCurrent()
            audioView.audioRecorder.startAudioRecord()
            audioView.timerRecording = NSTimer.scheduledTimerWithTimeInterval(1.0, target: audioView, selector: "timerCheckOnRecording", userInfo: nil, repeats: true)
            audioView.timerRecording.fire()
        }

    }
    
    //MARK: AudioViewDelegate
    
    func finishRecord() {
        self.btRecording.setTitle("Send", forState: UIControlState.Normal)        
    }
    
    func didStartPlaying(view: URAudioView) {
        
    }
    
    //MARK: AudioRecorderManagerDelegate
    
    func audioRecorderDidFinish(path: String) {
        
        audioMedia = URAudioMedia()
        audioMedia!.path = path
        
        audioView.setupAudioPlayerWithURL(URAudioRecorderManager.outputURLFile)
    }
    
    //MARK: Class Methods
    
}
