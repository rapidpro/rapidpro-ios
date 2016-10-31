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
    func audioRecorderDidFinish(_ path:String)
}

class URAudioRecorderManager: NSObject,  AVAudioRecorderDelegate {

    static let outputURLFile = URL(fileURLWithPath: URFileUtil.outPutURLDirectory.appendingPathComponent("audio.m4a"))
//    static let audiosPlaying = []
    
    var recorder:AVAudioRecorder!
    var delegate:URAudioRecorderManagerDelegate?
    
    static let recordSettings = [
        AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
        AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
        AVNumberOfChannelsKey: 1,
        AVSampleRateKey : 8000.0
    ] as [String : Any]
    
    func startAudioRecord() {
        
        do {
            
            URFileUtil.removeFile(URAudioRecorderManager.outputURLFile)
            
            recorder = try AVAudioRecorder(url: URAudioRecorderManager.outputURLFile, settings: URAudioRecorderManager.recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true)
                recorder.record()
            }catch let error as NSError {
                print(error)
            }
            

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func stopRecording() {
        recorder.stop()
        closeSession()
    }
    
    func closeSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }catch let error as NSError {
            print(error)
        }
    }
    
    //MARK: AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if let delegate = self.delegate {
            delegate.audioRecorderDidFinish(URAudioRecorderManager.outputURLFile.path)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
}
