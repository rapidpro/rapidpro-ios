//
//  URFCMRegistratoinAPI.swift
//  ureport
//
//  Created by Dielson Sales on 03/07/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit
import Alamofire

class URFCMRegistratoinAPI {

    private static let URL = "https://iid.googleapis.com/iid/"

    static func registerOnTopic(key: String, pushIdentity: String, topic: String) {
        let headers = [
            "Authorization": "key=\(key)"
        ]
        _ = Alamofire.request("\(URL)\(pushIdentity)/rel/topics/\(topic)", method: .post, headers: headers)
    }

    static func unregisterFromTopic(key: String, pushIdentity: String, topic: String) {
        let headers = [
            "Authorizaiton": "key=\(key)"
        ]
        _ = Alamofire.request("\(URL)\(pushIdentity)/rel/topics/\(topic)", method: .delete, headers: headers)
    }

}
