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

    static let outPutURL = NSURL(fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]).URLByAppendingPathComponent("video_upload")
    
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
    
    class func generateThumbnail(url : NSURL) -> UIImage?{
        let asset = AVAsset(URL: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSizeMake(100, 100);

        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let image = try assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
            let frameImg = UIImage(CGImage: image)
            
            return frameImg
        }catch let error as NSError {
            print("error on generate image thumbnail \(error.localizedDescription)")
            return nil
        }
    }
    
}
