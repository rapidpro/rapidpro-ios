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
        case .photos:
            return "no_hardware_permission_photo".localized
        case .camera:
            return "no_hardware_permission_camera".localized
        case .microphone:
            return "no_hardware_permission_microphone".localized
        case .contacts:
            return "no_hardware_permission_contact".localized
        case .reminders:
            return NSLocalizedString("Proposer needs to access your Reminders to create reminder.", comment: "")
        case .calendar:
            return NSLocalizedString("Proposer needs to access your Calendar to create event.", comment: "")
        case .location:
            return NSLocalizedString("Proposer needs to get your Location to share to your friends.", comment: "")
        case .notifications:
            return NSLocalizedString("App needs to get your Location to share to your friends.", comment: "")
        }
    }
    
    var noPermissionMessage: String {
        switch self {
        case .photos:
            return "no_hardware_permission_photo".localized
        case .camera:
            return "no_hardware_permission_camera".localized
        case .microphone:
            return "no_hardware_permission_microphone".localized
        case .contacts:
            return "no_hardware_permission_contact".localized
        case .reminders:
            return NSLocalizedString("Proposer needs to access your Reminders to create reminder.", comment: "")
        case .calendar:
            return NSLocalizedString("Proposer needs to access your Calendar to create event.", comment: "")
        case .location:
            return NSLocalizedString("Proposer needs to get your Location to share to your friends.", comment: "")
        case .notifications:
            return NSLocalizedString("App needs to get your Location to share to your friends.", comment: "")
        }
    }
}

extension UIViewController {

    fileprivate func showDialogWithTitle(_ title: String?, message: String, cancelTitle: String, confirmTitle: String, withCancelAction cancelAction : (() -> Void)?, confirmAction: (() -> Void)?) {

        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let cancelAction: UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                cancelAction?()
            }
            alertController.addAction(cancelAction)

            let confirmAction: UIAlertAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
                confirmAction?()
            }
            alertController.addAction(confirmAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showProposeMessageIfNeedFor(_ resource: PrivateResource, andTryPropose propose: @escaping Propose) {

        if resource.isNotDeterminedAuthorization {
            showDialogWithTitle(nil, message: resource.proposeMessage, cancelTitle: "cancel_dialog_button".localized, confirmTitle: "Ok", withCancelAction: nil, confirmAction: {
                propose()
            })

        } else {
            propose()
        }
    }

    func alertNoPermissionToAccess(_ resource: PrivateResource) {

        showDialogWithTitle(nil, message: resource.noPermissionMessage, cancelTitle: "cancel_dialog_button".localized, confirmTitle: "Ok", withCancelAction: nil, confirmAction: {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
    }
}
