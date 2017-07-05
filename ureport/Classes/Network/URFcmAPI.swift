//
//  URFCMRegistratoinAPI.swift
//  ureport
//
//  Created by Dielson Sales on 03/07/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire

class URFcmAPI {

    private static let gcmCompatURL = "https://iid.googleapis.com/iid"
    private static let fcmURL = "https://fcm.googleapis.com"

    static func registerOnTopic(pushIdentity: String, topic: String) {
        let headers = [
            "Authorization": URConstant.Fcm.GCM_AUTHORIZATION
        ]
        _ = Alamofire.request("\(gcmCompatURL)/\(pushIdentity)/rel/topics/\(topic)", method: .post, headers: headers).response(completionHandler: { defaultDataResponse in
            print("Request done")
        })
    }

    static func unregisterFromTopic(pushIdentity: String, topic: String) {
        let headers = [
            "Authorizaiton": URConstant.Fcm.GCM_AUTHORIZATION
        ]
        _ = Alamofire.request("\(gcmCompatURL)/\(pushIdentity)/rel/topics/\(topic)", method: .delete, headers: headers).response(completionHandler: {
             defaultDataResponse in
            print("Request done")
        })
    }

    static func sendChatNotification(data: [String: Any]) {
        let headers = [
            "Authorization": URConstant.Fcm.GCM_AUTHORIZATION
        ]
        _ = Alamofire.request("\(fcmURL)/fcm/send", method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).response(completionHandler: { defaultDataResponse in
            print("Message sent")
        })
    }
}
