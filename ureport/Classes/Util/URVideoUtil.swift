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

    static let outputURLFile = NSURL(fileURLWithPath: URFileUtil.outPutURLDirectory.stringByAppendingPathComponent("video.mp4"))
    
    class func compressVideo(inputURL: NSURL, handler:(session: AVAssetExportSession) -> Void) {
        
        let urlAsset = AVURLAsset(URL: inputURL, options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality)!
        
        URFileUtil.removeFile(outputURLFile)
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(URFileUtil.outPutURLDirectory as String, withIntermediateDirectories: true, attributes: nil)
            
            exportSession.outputURL = outputURLFile
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.outputFileType = AVFileTypeMPEG4
            
            exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                handler(session: exportSession)
            }
            
        } catch let error as NSError {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
    }
    
    class func generateThumbnail(url : NSURL) -> UIImage?{
        let asset = AVAsset(URL: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
//        assetImgGenerate.maximumSize = CGSizeMake(1024, 768);

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
