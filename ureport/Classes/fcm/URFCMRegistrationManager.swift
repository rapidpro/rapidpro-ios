//
//  URFCMRegistrationService.swift
//  ureport
//
//  Created by Dielson Sales on 03/07/17.
//  Copyright © 2017 ilhasoft. All rights reserved.
//

import UIKit

class URFCMRegistrationManager {

    func onFCMRegistered(pushIdentity: String, user: URUser) {
        registerToChatTopics(pushIdentity: pushIdentity, user: user)
        registerToStoryTopics(pushIdentity: pushIdentity, user: user)
    }

    // MARK:- Private methods

    private func registerToChatTopics(pushIdentity: String, user: URUser) {
        
    }

    private func registerToStoryTopics(pushIdentity: String, user: URUser) {
    }

}
