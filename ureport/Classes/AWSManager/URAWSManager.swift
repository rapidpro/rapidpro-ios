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

class URAWSManager {
   
    class func uploadAudio(_ audioMedia:URAudioMedia,uploadPath:URUploadPath,completion:@escaping (URMedia?) -> Void) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + "-\(NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64))-iOS-audio.m4a"
        
        let transferManager = AWSS3TransferManager.default()
        
        let uploadFileURL = URL(fileURLWithPath: audioMedia.path)
        
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
            uploadRequest.body = uploadFileURL
            uploadRequest.key = fileName
            
            transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask?) -> Any? in
                if let error = task?.error {
                    print("Error on send file to AWS \(error.localizedDescription)")
                } else {
                    let file = URMedia()
                    
                    file.type = URConstant.Media.AUDIO
                    file.id = fileName
                    file.url = "\(URConstant.AWS.URL_STORAGE(uploadPath))/\(fileName)"
                    file.metadata = audioMedia.metadata
                    
                    completion(file)
                }
                return nil
            })
        }
    }
    
    class func uploadFile(_ localMedia: URLocalMedia, uploadPath: URUploadPath, completion: @escaping (URMedia?) -> Void) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + "-\(NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000) as Int64))\(localMedia.metadata!["filename"] as! String)"
        
        let transferManager = AWSS3TransferManager.default()
        
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.body = URL(fileURLWithPath: localMedia.path)
            uploadRequest.key = fileName
            uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
            
            transferManager.upload(uploadRequest).continueWith{ (task:AWSTask?) -> Any? in
                
                if let error = task?.error {
                    print("Error on send file to AWS \(error.localizedDescription)")
                } else {
                    
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
    }
    
    class func uploadImage(_ image:UIImage, uploadPath: URUploadPath,completion:@escaping (URMedia?) -> Void) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + "-\(NSNumber(value: Int64(URDateUtil.currentDate().timeIntervalSince1970 * 1000) as Int64))-iOS.jpg"
        let filePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName).path
        let imageData = UIImageJPEGRepresentation(image, 0.2)
        try? imageData!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        
        let transferManager = AWSS3TransferManager.default()
        
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.body = URL(fileURLWithPath: filePath)
            uploadRequest.key = fileName
            uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
            
         transferManager.upload(uploadRequest).continueWith(block: {
                (task:AWSTask?) -> Any? in
                
                if let error = task?.error {
                    print("Error on send file to AWS \(error.localizedDescription)")
                } else {
                    let picture = URMedia()
                    
                    picture.type = URConstant.Media.PICTURE
                    picture.id = fileName
                    picture.url = "\(URConstant.AWS.URL_STORAGE(uploadPath))/\(fileName)"
                    
                    completion(picture)
                }
                
                return nil
            })
        }
    }
    
    class func uploadVideo(_ videoPhone:URVideoPhoneMedia,uploadPath:URUploadPath,completionVideoUpload:@escaping (URMedia?) -> Void) {
        
        URVideoUtil.compressVideo(URL(fileURLWithPath: videoPhone.path)) { (session) -> Void in
            
            if session.status == .completed {
                
                let fileName = ProcessInfo.processInfo.globallyUniqueString + "-\(NSNumber(value: Int64(URDateUtil.currentDate().timeIntervalSince1970 * 1000) as Int64))-iOS.mp4"
                
                let transferManager = AWSS3TransferManager.default()
                
                if let uploadRequest = AWSS3TransferManagerUploadRequest() {
                    
                    uploadRequest.body = URVideoUtil.outputURLFile
                    uploadRequest.key = fileName
                    uploadRequest.bucket = URConstant.AWS.S3_BUCKET_NAME(uploadPath)
                    
                    transferManager.upload(uploadRequest).continueWith{ (task:AWSTask?) -> Any? in
                        
                        if let error = task?.error {
                            print("Error on send file to AWS \(error.localizedDescription)")
                        } else {
                            
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
                    
                }
                
            } else {
                print(session.error)
            }
            
        }
        
    }
    
}
