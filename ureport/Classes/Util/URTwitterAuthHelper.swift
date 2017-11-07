//
//  URTwitterAuthHelper.swift
//  ureport
//
//  Created by Daniel Amaral on 09/11/16.
//  Copyright © 2016 ilhasoft. All rights reserved.
//

import UIKit
import STTwitter

class URTwitterAuthHelper {
    
    static let TWITTER_CONSUMER_KEY = URConstant.SocialNetwork.TWITTER_APP_ID()
    static let TWITTER_CONSUMER_SECRET_KEY = URConstant.SocialNetwork.TWITTER_CONSUMER_SECRET()
    
    static func getAccessTokenKeyAndTokenSecret(_ twitterAccount:ACAccount, completion:@escaping (_ accessTokenKey:String?,_ accessTokenSecret:String?) -> Void) -> Void {
        
        let twitter = STTwitterAPI(oAuthConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY)
        twitter!.postReverseOAuthTokenRequest({ (authenticationHeader) -> Void in
            let twitterAPIOS = STTwitterAPI.twitterAPIOS(with: twitterAccount)
            twitterAPIOS!.verifyCredentials(successBlock: { (username) -> Void in
                twitterAPIOS!.postReverseAuthAccessToken(withAuthenticationHeader: authenticationHeader, successBlock: { (oAuthToken, oAuthTokenSecret, userID, screenName) -> Void in
                    completion(oAuthToken,oAuthTokenSecret)
                    
                }, errorBlock: { (error) -> Void in
                    completion(nil,nil)
                })
            }, errorBlock: { (error) -> Void in
                completion(nil,nil)
            })
        }, errorBlock: { (error) -> Void in
            completion(nil,nil)
        })
    }

}
