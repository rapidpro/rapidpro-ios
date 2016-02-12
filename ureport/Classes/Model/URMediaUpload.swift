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
                let videoID = URYoutubeUtil.getYoutubeVideoID(youtubeVideoMedia.url)
                media.id = videoID
                media.url = URConstant.Youtube.COVERIMAGE.stringByReplacingOccurrencesOfString("%@", withString: videoID!)
                media.type = URConstant.Media.VIDEO
                
                mediaList.append(media)
                
                if mediaList.count == medias.count {
                    completion(medias: mediaList)
                }
                
            }else if let videoPhoneMedia = media as? URVideoPhoneMedia {
                
                URAWSManager.uploadVideo(videoPhoneMedia, uploadPath: .Stories, completionVideoUpload: { (video:URMedia?) -> Void in
                    mediaList.append(video!)
                    
                    if mediaList.count == medias.count {
                        completion(medias: mediaList)
                    }
                    
                })
                
            }else if let imageMedia = media as? URImageMedia {
                URAWSManager.uploadImage(imageMedia.image, uploadPath: .Stories, completion: { (image:URMedia?) -> Void in
                    mediaList.append(image!)
                    
                    if mediaList.count == medias.count {
                        completion(medias: mediaList)
                    }
                    
                })
            }else if let media = media as? URLocalMedia {

                
            }
            
        }
    }
    
}
