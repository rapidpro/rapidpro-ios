//
//  URMediaUpload.swift
//  ureport
//
//  Created by Daniel Amaral on 05/02/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit

class URMediaUpload: NSObject {

    class func uploadMedias(medias:[URMedia],completion:(medias:[URMedia]) -> Void) {
        
        var mediaList:[URMedia] = []
        
        for media in medias {
            
            if let youtubeVideoMedia = media as? URVideoMedia {
                
                let media = URMedia()
                media.type = URConstant.Media.VIDEO
                media.url = youtubeVideoMedia.url
                media.id = youtubeVideoMedia.id
                media.isCover = youtubeVideoMedia.isCover
                
                mediaList.append(media)
                
                if mediaList.count == medias.count {
                    completion(medias: mediaList)
                }
                
            }else if let videoPhoneMedia = media as? URVideoPhoneMedia {
                
                URAWSManager.uploadVideo(videoPhoneMedia, uploadPath: .Stories, completionVideoUpload: { (video:URMedia?) -> Void in
                    
                    video!.isCover = videoPhoneMedia.isCover
                    
                    mediaList.append(video!)
                    
                    if mediaList.count == medias.count {
                        completion(medias: mediaList)
                    }
                    
                })
                
            }else if let imageMedia = media as? URImageMedia {
                URAWSManager.uploadImage(imageMedia.image, uploadPath: .Stories, completion: { (media:URMedia?) -> Void in
                    
                    media!.isCover = imageMedia.isCover
                    mediaList.append(media!)
                    
                    imageMedia.image = nil
                    
                    if mediaList.count == medias.count {
                        completion(medias: mediaList)
                    }
                    
                })
            }else if let fileMedia = media as? URLocalMedia {

                URAWSManager.uploadFile(fileMedia, uploadPath: .Stories, completion: { (media:URMedia?) -> Void in
                    
                    media!.isCover = fileMedia.isCover
                    mediaList.append(media!)
                    
                    if mediaList.count == medias.count {
                        completion(medias: mediaList)
                    }
                    
                })
                
            }else if let audioMedia = media as? URAudioMedia {
                
                URAWSManager.uploadAudio(audioMedia, uploadPath: .Stories, completion: { (media:URMedia?) -> Void in
                    
                    media!.isCover = audioMedia.isCover
                    mediaList.append(media!)
                    
                    if mediaList.count == medias.count {
                        completion(medias: mediaList)
                    }
                    
                })
                
            }
            
        }
    }
    
}
