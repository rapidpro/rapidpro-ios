//
//  UIViewController+Proposer.swift
//  Lady
//
//  Created by NIX on 15/7/11.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit
import Proposer

extension PrivateResource {

    var proposeMessage: String {
        switch self {
        case .Photos:
            return "no_hardware_permission_photo".localized
        case .Camera:
            return "no_hardware_permission_camera".localized
        case .Microphone:
            return "no_hardware_permission_microphone".localized
        case .Contacts:
            return "no_hardware_permission_contact".localized
        case .Reminders:
            return NSLocalizedString("Proposer need to access your Reminders to create reminder.", comment: "")
        case .Calendar:
            return NSLocalizedString("Proposer need to access your Calendar to create event.", comment: "")
        case .Location:
            return NSLocalizedString("Proposer need to get your Location to share to your friends.", comment: "")
        }
    }
    
    var noPermissionMessage: String {
        switch self {
        case .Photos:
            return "no_hardware_permission_photo".localized
        case .Camera:
            return "no_hardware_permission_camera".localized
        case .Microphone:
            return "no_hardware_permission_microphone".localized
        case .Contacts:
            return "no_hardware_permission_contact".localized
        case .Reminders:
            return NSLocalizedString("Proposer need to access your Reminders to create reminder.", comment: "")
        case .Calendar:
            return NSLocalizedString("Proposer need to access your Calendar to create event.", comment: "")
        case .Location:
            return NSLocalizedString("Proposer need to get your Location to share to your friends.", comment: "")
        }
    }
}

extension UIViewController {

    private func showDialogWithTitle(title: String?, message: String, cancelTitle: String, confirmTitle: String, withCancelAction cancelAction : (() -> Void)?, confirmAction: (() -> Void)?) {

        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .Cancel) { _ in
                cancelAction?()
            }
            alertController.addAction(cancelAction)

            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .Default) { _ in
                confirmAction?()
            }
            alertController.addAction(confirmAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func showProposeMessageIfNeedFor(resource: PrivateResource, andTryPropose propose: Propose) {

        if resource.isNotDeterminedAuthorization {
            showDialogWithTitle(nil, message: resource.proposeMessage, cancelTitle: "cancel_dialog_button".localized, confirmTitle: "Ok", withCancelAction: nil, confirmAction: {
                propose()
            })

        } else {
            propose()
        }
    }

    func alertNoPermissionToAccess(resource: PrivateResource) {

        showDialogWithTitle(nil, message: resource.noPermissionMessage, cancelTitle: "cancel_dialog_button".localized, confirmTitle: "Ok", withCancelAction: nil, confirmAction: {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        })
    }
}
