//
//  URAWSManager.swift
//  ureport
//
//  Created by Daniel Amaral on 15/09/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit
import AWSS3

enum URUploadPath:String {
    case Chat = "CHAT"
    case Stories = "STORIES"
    case User = "USER"
}


class URAWSManager: NSObject {
   
    class func uploadAudio(audioMedia:URAudioMedia,uploadPath:URUploadPath,completion:(URMedia?) -> Void) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString("-\(NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000)))-iOS-audio.m4a")
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest.body = NSURL(fileURLWithPath: audioMedia.path)
        uploadRequest.key = fileName
        uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
        
        transferManager.upload(uploadRequest).continueWithBlock { (task:AWSTask?) -> AnyObject! in
            if task!.error != nil{
                print("Error on send file to AWS \(task!.error)")
            }else {
                
                let file = URMedia()
                
                file.type = URConstant.Media.AUDIO
                file.id = fileName
                file.url = "\(URConstant.AWS.URL_STORAGE(uploadPath))/\(fileName)"
                file.metadata = audioMedia.metadata
                
                completion(file)
            }
            return nil
        }
        
    }
    
    class func uploadFile(localMedia:URLocalMedia,uploadPath:URUploadPath,completion:(URMedia?) -> Void) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString("-\(NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000)))\(localMedia.metadata!["filename"] as! String)")
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest.body = NSURL(fileURLWithPath: localMedia.path)
        uploadRequest.key = fileName
        uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
        
        transferManager.upload(uploadRequest).continueWithBlock { (task:AWSTask?) -> AnyObject! in
            if task!.error != nil{
                print("Error on send file to AWS \(task!.error)")
            }else {
                
                let file = URMedia()
                
                file.type = URConstant.Media.FILE
                file.id = fileName
                file.url = "\(URConstant.AWS.URL_STORAGE(uploadPath))/\(fileName)"
                file.metadata = localMedia.metadata
                
                completion(file)
            }
            return nil
        }
        
    }
    
    class func uploadImage(image:UIImage,uploadPath:URUploadPath,completion:(URMedia?) -> Void) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString("-\(NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000)))-iOS.jpg")
        let filePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(fileName).path!
        let imageData = UIImageJPEGRepresentation(image, 0.2)
        imageData!.writeToFile(filePath, atomically: true)
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        uploadRequest.key = fileName
        uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
        
        transferManager.upload(uploadRequest).continueWithBlock { (task:AWSTask?) -> AnyObject! in
            if task!.error != nil{
                print("Error on send file to AWS \(task!.error)")
            }else {
                
                let picture = URMedia()
                
                picture.type = URConstant.Media.PICTURE
                picture.id = fileName
                picture.url = "\(URConstant.AWS.URL_STORAGE(uploadPath))/\(fileName)"

                completion(picture)
            }
            return nil
        }
        
    }
    
    class func uploadVideo(videoPhone:URVideoPhoneMedia,uploadPath:URUploadPath,completionVideoUpload:(URMedia?) -> Void) {
        
        URVideoUtil.compressVideo(NSURL(fileURLWithPath: videoPhone.path)) { (session) -> Void in
            
            if session.status == .Completed {
                
                let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString("-\(NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000)))-iOS.mp4")
                
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                
                uploadRequest.body = URVideoUtil.outputURLFile
                uploadRequest.key = fileName
                uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
                
                transferManager.upload(uploadRequest).continueWithBlock { (task:AWSTask?) -> AnyObject! in
                    if task!.error != nil{
                        print("Error on send file to AWS \(task!.error)")
                    }else {
                        
                        let video = URMedia()
                        
                        video.type = URConstant.Media.VIDEOPHONE
                        video.id = fileName
                        video.url = "\(URConstant.AWS.URL_STORAGE(uploadPath))/\(fileName)"
                        
                        URAWSManager.uploadImage(videoPhone.thumbnailImage, uploadPath: .Stories, completion: { (media) -> Void in
                            
                            video.thumbnail = media!.url
                            completionVideoUpload(video)
                            
                        })
                        
                    }
                    return nil
                }
                
            }else{
                print(session.error)
            }
            
        }
        
    }
    
}
