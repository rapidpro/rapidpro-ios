//
//  URAudioRecorderViewController.swift
//  ureport
//
//  Created by Daniel Amaral on 17/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation
import Proposer

protocol URAudioRecorderViewControllerDelegate {
    func newAudioRecorded(_ audioRecorderViewController:URAudioRecorderViewController,media:URMedia)
}

class URAudioRecorderViewController: UIViewController, URAudioRecorderManagerDelegate, AVAudioPlayerDelegate, URAudioViewDelegate {

    @IBOutlet weak var lbRecorder: UILabel!
    @IBOutlet weak var btRecording: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var bgAudioView: UIView!
    
    var delegate:URAudioRecorderViewControllerDelegate?
    
    let audioView = Bundle.main.loadNibNamed("URAudioView", owner: nil, options: nil)?[0] as! URAudioView
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
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        audioView.audioViewdelegate = self
        
        if let audioRemoteURL = audioView.audioRemoteURL {
            audioView.playAudioImmediately(audioRemoteURL,showPreloading: true)
        }else{
            self.btRecording.isHidden = false
            audioView.btPlay.isEnabled = false
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        audioMedia = nil

        if audioView.player != nil && audioView.player.isPlaying == true {
            audioView.player.stop()
        }

    }
    
    //MARK: Button Events
    
    @IBAction func btPlayTapped() {
        audioView.play()
    }
    
    @IBAction func btCancelTapped() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0)
            }, completion: { (finished) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "modalProfileDidClosed"), object: nil)
                self.dismiss(animated: true, completion: nil)
        }) 
    }
    
    @IBAction func btRecordTapped() {
        
        if let audioMedia = audioMedia {
            if let delegate = delegate {
                audioMedia.metadata = ["duration":Int(audioView.player.duration) as AnyObject]
                delegate.newAudioRecorded(self, media: audioMedia)
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        
        if audioView.isRecording == true {
            audioView.needFinishRecord()
        }else{
            
            proposeToAccess(PrivateResource.Microphone, agreed: {
                
                self.audioView.isRecording = true
                self.audioView.audioRecorder = URAudioRecorderManager()
                self.audioView.audioRecorder.delegate = self
                self.btRecording.setTitle("Stop", forState: UIControlState.Normal)
                self.audioView.startTimeRecording = CFAbsoluteTimeGetCurrent()
                self.audioView.audioRecorder.startAudioRecord()
                self.audioView.timerRecording = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self.audioView, selector: #selector(self.audioView.timerCheckOnRecording), userInfo: nil, repeats: true)
                self.audioView.timerRecording.fire()
                
                }, rejected: {
                    self.alertNoPermissionToAccess(PrivateResource.Microphone)
            })
            
        }

    }
    
    //MARK: AudioViewDelegate
    
    func finishRecord() {
        self.btRecording.setTitle("Send", for: UIControlState())        
    }
    
    func didStartPlaying(_ view: URAudioView) {
        
    }
    
    //MARK: AudioRecorderManagerDelegate
    
    func audioRecorderDidFinish(_ path: String) {
        
        audioMedia = URAudioMedia()
        audioMedia!.path = path
        
        audioView.setupAudioPlayerWithURL(URAudioRecorderManager.outputURLFile)
    }
    
    //MARK: Class Methods
    
}
