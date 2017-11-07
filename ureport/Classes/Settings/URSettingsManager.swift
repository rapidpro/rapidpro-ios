//
//  URSettingsManager.swift
//  ureport
//
//  Created by Dielson Sales on 03/07/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit

class URSettingsManager {

    private struct Constants {
        static let keyFCMToken = "KEY_FCM_TOKEN"
    }

    static func saveFCMToken(fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: Constants.keyFCMToken)
    }

    static func getFCMToken() -> String? {
        return UserDefaults.standard.value(forKey: Constants.keyFCMToken) as? String
    }
}
