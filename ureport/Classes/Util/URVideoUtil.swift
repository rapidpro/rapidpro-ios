//
//  URVideoUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 02/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import AVFoundation

class URVideoUtil: NSObject {

    static let outPutURL = NSURL(fileURLWithPath:NSTemporaryDirectory()).URLByAppendingPathComponent("video_upload")
    
    class func compressVideo(inputURL: NSURL, handler:(session: AVAssetExportSession) -> Void) {
        
        let urlAsset = AVURLAsset(URL: inputURL, options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality)!
        
        exportSession.outputURL = outPutURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in            
            handler(session: exportSession)
        }
        
    }
    
}
