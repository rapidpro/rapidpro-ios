//
//  URAudioRecorderManager.swift
//  ureport
//
//  Created by Daniel Amaral on 17/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation

protocol URAudioRecorderManagerDelegate {
    func audioRecorderDidFinish(path:String)
}

class URAudioRecorderManager: NSObject,  AVAudioRecorderDelegate {

    static let outPutURL = NSURL(fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]).URLByAppendingPathComponent("audio_upload")
    var recorder:AVAudioRecorder!
    
    var delegate:URAudioRecorderManagerDelegate?
    
    static let recordSettings = [
        AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatAppleLossless),
        AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
        AVEncoderBitRateKey : 32000.0,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey : 44100.0
    ]
    
    func startAudioRecord() {
        do {
            recorder = try AVAudioRecorder(URL: URAudioRecorderManager.outPutURL, settings: URAudioRecorderManager.recordSettings)
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if let delegate = self.delegate {
            delegate.audioRecorderDidFinish(URAudioRecorderManager.outPutURL.path!)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
}
