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
}

class URAWSManager: NSObject {
   
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
            ProgressHUD.dismiss()
            if task!.error != nil{
                print(task!.error)
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
                
                let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString("-\(NSNumber(longLong:Int64(NSDate().timeIntervalSince1970 * 1000)))-iOS.MOV")
                
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                
                uploadRequest.body = NSURL(fileURLWithPath: URVideoUtil.outPutURL.path!)
                uploadRequest.key = fileName
                uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
                
                transferManager.upload(uploadRequest).continueWithBlock { (task:AWSTask?) -> AnyObject! in
                    ProgressHUD.dismiss()
                    if task!.error != nil{
                        print(task!.error)
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
                print(session.status.rawValue)
                print(session.error!.localizedDescription)
            }
            
        }
        
    }
    
}
