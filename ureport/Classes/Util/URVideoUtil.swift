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

    static let outputURLFile = URL(fileURLWithPath: URFileUtil.outPutURLDirectory.appendingPathComponent("video.mp4"))
    
    class func compressVideo(_ inputURL: URL, handler:@escaping (_ session: AVAssetExportSession) -> Void) {
        
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality)!
        
        URFileUtil.removeFile(outputURLFile)
        
        do {
            try FileManager.default.createDirectory(atPath: URFileUtil.outPutURLDirectory as String, withIntermediateDirectories: true, attributes: nil)
            
            exportSession.outputURL = outputURLFile
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.outputFileType = AVFileTypeMPEG4
            
            exportSession.exportAsynchronously { () -> Void in
                handler(exportSession)
            }
            
        } catch let error as NSError {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
    }
    
    class func generateThumbnail(_ url : URL) -> UIImage?{
        let asset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
//        assetImgGenerate.maximumSize = CGSizeMake(1024, 768);

        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let image = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg = UIImage(cgImage: image)
            
            return frameImg
        }catch let error as NSError {
            print("error on generate image thumbnail \(error.localizedDescription)")
            return nil
        }
    }
    
}
