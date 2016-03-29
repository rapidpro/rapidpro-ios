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

class URAudioRecorderViewController: UIViewController, URAudioRecorderManagerDelegate {

    @IBOutlet weak var lbRecorder: UILabel!
    @IBOutlet weak var lbCurrentTime: UILabel!
    @IBOutlet weak var lbMaxTime: UILabel!
    @IBOutlet weak var btPlay: UIButton!
    @IBOutlet weak var btRecording: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewBGTimeline: UIView!
    @IBOutlet weak var viewTimeline: UIView!
    @IBOutlet weak var timeLineWidth: NSLayoutConstraint!
    
    var isVisible:Bool!
    var finishRecording:Bool!
    var delegate:URAudioRecorderViewControllerDelegate?
    
    var startTime:CFAbsoluteTime!
    var timer:NSTimer!
    
    let maximumTime = 20
    
    init() {
        super.init(nibName: "URAudioRecorderViewController", bundle: nil)
        isVisible = false
        finishRecording = false
        
        let frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height, width: UIScreen.mainScreen().bounds.size.width, height: self.view.frame.size.height)
        self.view.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider()
        self.lbMaxTime.text = "00:20"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Button Events
    
    @IBAction func btPlayTapped() {
        
    }
    
    @IBAction func btCancelTapped() {
        self.toggleView()        
    }
    
    @IBAction func btRecordTapped() {
        if finishRecording == true {
            //CallDelegate
        }else{
//            let audioRecorder = URAudioRecorderManager()
//            audioRecorder.delegate = self
            self.btRecording.setTitle("Stop", forState: UIControlState.Normal)
            startTime = CFAbsoluteTimeGetCurrent()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerCheck", userInfo: nil, repeats: true)
            timer.fire()
//            audioRecorder.startAudioRecord()
        }
    }
    
    //MARK: AudioRecorderManagerDelegate
    
    func audioRecorderDidFinish(path: String) {

    }
    
    //MARK: Class Methods
    
    func setupSlider() {
        slider.continuous = true
        slider.minimumValue = 0
        slider.maximumValue = Float(maximumTime)
    }
    
    func timerCheck() {
        let seconds = Int(CFAbsoluteTimeGetCurrent() - startTime)
        
        slider.setValue(Float(seconds), animated: true)
        
        if seconds <= 9 {
            self.lbCurrentTime.text = "00:0\(Int(CFAbsoluteTimeGetCurrent() - startTime))"
        }else if seconds <= 20 {
            self.lbCurrentTime.text = "00:\(Int(CFAbsoluteTimeGetCurrent() - startTime))"
        }else{
            timer.invalidate()
            needFinishRecord()
        }
        
    }
    
    func needFinishRecord() {
        self.btRecording.setTitle("Send", forState: UIControlState.Normal)
        finishRecording = true
    }
    
    func toggleView() {
        
        if !isVisible {
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                let frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
                self.view.frame = frame
                }) { (finish) -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
                    })
            }
            isVisible = true
        }else{
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
                }) { (finish) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        let frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
                        self.view.frame = frame
                    })
            }
            isVisible = false
        }
        
    }

}
