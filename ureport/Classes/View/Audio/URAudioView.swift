//
//  URAudioView.swift
//  ureport
//
//  Created by Daniel Amaral on 16/03/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation

protocol URAudioViewDelegate {
    func finishRecord()
}

class URAudioView: UIView, AVAudioPlayerDelegate, URAudioRecorderManagerDelegate {

    var player:AVAudioPlayer!
    var audioRemoteURL:String?
    
    @IBOutlet weak var slider: UISlider!    
    @IBOutlet weak var btPlay: UIButton!
    @IBOutlet weak var lbCurrentTime: UILabel!
    @IBOutlet weak var lbMaxTime: UILabel!
    
    var isRecording:Bool!
    var delegate:URAudioRecorderViewControllerDelegate?
    var audioViewdelegate:URAudioViewDelegate?
    
    var startTimeRecording:CFAbsoluteTime!
    var startTimePlayBack:CFAbsoluteTime!
    var timerRecording:NSTimer!
    var timerPlayback:NSTimer!
    
    var recordedSeconds = 0
    let maximumTime = 50
    var audioMedia:URAudioMedia?
    var audioRecorder:URAudioRecorderManager!
    
    var playAudioImmediately:Bool!
    
    override func awakeFromNib() {
        isRecording = false
    }
    
    //MARK: AudioRecorderManagerDelegate
    
    func audioRecorderDidFinish(path: String) {
        
        audioMedia = URAudioMedia()
        audioMedia!.path = path
        
        setupAudioPlayerWithURL(URAudioRecorderManager.outputURLFile)
    }
    
    //MARK: Class Methods
    
    func playAudioImmediately(audioURL:String,showPreloading:Bool) {
        if showPreloading == true {
            ProgressHUD.show(nil)
        }
        URDownloader.download(NSURL(string: audioURL)!) { (data) -> Void in
            if let data = data {
                dispatch_async(dispatch_get_main_queue(), {
                    ProgressHUD.dismiss()
                    self.setupAudioPlayerWithURL(NSURL(string: URFileUtil.writeFile(data))!)
                })
            }else{
                ProgressHUD.showError("Error")
            }
        }
    }
    
    func setupSliderWithPlayMode() {
        
        recordedSeconds = recordedSeconds == 0 ? Int(player.duration) : recordedSeconds
        
        self.btPlay.enabled = true
        self.btPlay.setImage(UIImage(named: "play_audio"), forState: UIControlState.Normal)
        
        slider.value = 0
        slider.minimumValue = 0
        slider.maximumValue = Float(recordedSeconds)
        
        self.lbCurrentTime.text = "00:00"
        
        self.lbMaxTime.text = getDurationString(recordedSeconds)
        
        var thumbImage = UIImage(named: "cursor_audio")
        let imageSize = CGSize(width: 23, height: 23)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        thumbImage!.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slider.setThumbImage(thumbImage, forState: UIControlState.Normal)
    }
    
    func setupAudioPlayerWithURL(url:NSURL) {
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            
            setupSliderWithPlayMode()
            
            if audioRemoteURL != nil {
                play()
            }
            
        }catch let error as NSError {
            self.btPlay.enabled = false
            ProgressHUD.showError("Error on load Audio, try again.", interaction: true)
            print(error.localizedDescription)
        }
    }
    
    func play() {
        if !player.playing {
            NSNotificationCenter.defaultCenter().postNotificationName("didStartPlaying", object: self)
            self.btPlay.setImage(UIImage(named: "ic_pause_blue"), forState: UIControlState.Normal)
            startTimePlayBack = CFAbsoluteTimeGetCurrent()
            player.play()
            timerPlayback = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerCheckOnPlayBlack), userInfo: nil, repeats: true)
            timerPlayback.fire()
        }else{
            self.btPlay.setImage(UIImage(named: "play_audio"), forState: UIControlState.Normal)
            timerPlayback.invalidate()
            player.pause()
        }
    }
    
    func setupSlider() {
        if isRecording == false {
            slider.setThumbImage(UIImage(), forState: UIControlState.Normal)
            slider.value = 0
            slider.continuous = true
            slider.minimumValue = 0
            slider.maximumValue = Float(maximumTime)
        }
    }
    
    func timerCheckOnRecording() {
        recordedSeconds = Int(CFAbsoluteTimeGetCurrent() - startTimeRecording)
        
        UIView.animateWithDuration(1.5, animations: {
            self.slider.setValue(Float(self.recordedSeconds), animated:true)
        })
        
        self.lbCurrentTime.text = getDurationString(recordedSeconds)
        
        if recordedSeconds == maximumTime {
            needFinishRecord()
            return
        }
        
    }
    
    func needFinishRecord() {
        if let delegate = audioViewdelegate {
            delegate.finishRecord()
        }
        isRecording = false
        timerRecording.invalidate()
        audioRecorder.stopRecording()
        setupSlider()
    }
    
    func timerCheckOnPlayBlack() {
        
        dispatch_async(dispatch_get_main_queue(),{
            if self.player.currentTime == 0 {
                self.slider.value = 0
            }else{
                UIView.animateWithDuration(1.5, animations: {
                    self.slider.setValue(Float(self.player.currentTime), animated:true)
                })
            }
        })
        
        self.lbCurrentTime.text = getDurationString(Int(self.player.currentTime))
        
        if Int(self.player.currentTime) == recordedSeconds - 1 {
            timerPlayback.invalidate()
            setupSliderWithPlayMode()
            return
        }
        
    }
    
    func getDurationString(seconds:Int) -> String{
        var seconds = seconds
        let minutes = (seconds % 3600) / 60
        seconds = seconds % 60
        return "\(URAudioView.getTwoDigitString(minutes)):\(URAudioView.getTwoDigitString(seconds))"
    }
    
    class func getTwoDigitString(number:Int) -> String{
        if number == 0 {
            return "00"
        }
        
        if number / 10 == 0 {
            return "0\(number)"
        }
        
        return String(number)
        
    }
    
    //MARK: UI Events
    
    @IBAction func sliderMoved(sender: UISlider) {
        
        self.lbCurrentTime.text = getDurationString(Int(self.player.currentTime))
        
        if player.playing == true {
            player.pause()
        }
        
        player.currentTime = NSTimeInterval(round(slider.value))
        play()
    }
    
    //MARK: Button Events
    
    @IBAction func btPlayTapped() {
        play()
    }
    
}
