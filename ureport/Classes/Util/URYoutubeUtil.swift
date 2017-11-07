//
//  URYoutubeUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 24/11/15.
//  Copyright © 2015 ilhasoft. All rights reserved.
//

import UIKit

class URYoutubeUtil {

    class func getYoutubeVideoID(_ strVideoUrl:String) -> String?{                
        
        if !strVideoUrl.contains("http://") && !strVideoUrl.contains("https://") {
            var strVideoUrl = strVideoUrl
            strVideoUrl = "https://\(strVideoUrl)"
        }
        let URLVideo = URL(string: strVideoUrl)
        
        print(URLVideo!.host)
        
        if URLVideo?.host != "youtube.com" && URLVideo?.host != "www.youtube.com" && URLVideo?.host != "youtu.be" && URLVideo?.host != "www.youtu.be" && URLVideo?.host != "m.youtube.com" {
            print("Só é permitido adicionar vídeos do YouTube.")
            return nil
        }
        
        do {
            let regex = try NSRegularExpression(pattern: ".+v=([^&]+)|.+/([^?]+)", options: .caseInsensitive)
            let match = regex.firstMatch(in: strVideoUrl, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, strVideoUrl.characters.count))
            if let match = match {
                if match.numberOfRanges < 2 {
                    print("URL do vídeo inválida. Por favor, verifique se a URL está correta e tente novamente.")
                    return nil
                }
                var range = match.rangeAt(1)
                if range.location == NSNotFound {
                    range = match.rangeAt(2)
                }
                return (strVideoUrl as NSString).substring(with: range)
            }
        } catch {
            print("URL do vídeo inválida. Por favor, verifique se a URL está correta e tente novamente.")
            return nil
        }
        return nil
    }
    
}
