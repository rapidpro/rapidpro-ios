//
//  URYoutubeUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 24/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URYoutubeUtil: NSObject {

    class func getYoutubeVideoID(strVideoUrl:String) -> String?{
        
        if !strVideoUrl.containsString("http://") && !strVideoUrl.containsString("https://") {
            var strVideoUrl = strVideoUrl
            strVideoUrl = "https://\(strVideoUrl)"
        }
        let URLVideo = NSURL(string: strVideoUrl)
        
        print(URLVideo!.host)
        
        if URLVideo?.host != "youtube.com" && URLVideo?.host != "www.youtube.com" && URLVideo?.host != "youtu.be" && URLVideo?.host != "www.youtu.be" && URLVideo?.host != "m.youtube.com" {
            print("Só é permitido adicionar vídeos do YouTube.")
            return nil
        }
        
        do {
            let regex = try NSRegularExpression(pattern: ".+v=([^&]+)|.+/([^?]+)", options: .CaseInsensitive)
            let match = regex.firstMatchInString(strVideoUrl, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, strVideoUrl.characters.count))
            if let match = match {
                if match.numberOfRanges < 2 {
                    print("URL do vídeo inválida. Por favor, verifique se a URL está correta e tente novamente.")
                    return nil
                }
                var range = match.rangeAtIndex(1)
                if range.location == NSNotFound {
                    range = match.rangeAtIndex(2)
                }
                return (strVideoUrl as NSString).substringWithRange(range)
            }
        } catch {
            print("URL do vídeo inválida. Por favor, verifique se a URL está correta e tente novamente.")
            return nil
        }
        return nil
    }
    
}
