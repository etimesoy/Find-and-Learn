//
//  UIViewController+Extensions.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 08.04.2022.
//

import Foundation
import UIKit

extension UIViewController {
    func showAskAlert(message: String, handler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(
            title: R.string.localizable.alert_title(),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: R.string.localizable.alert_confirm(),
            style: .default,
            handler: handler)
        )
        alert.addAction(UIAlertAction(
            title: R.string.localizable.alert_cancel(),
            style: .cancel)
        )
        present(alert, animated: true)
    }
    
    func showOkAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
    
    func showServerProblemAlert() {
        showOkAlert(
            title: R.string.localizable.validation_error_server_problems_title(),
            message: R.string.localizable.validation_error_server_problems_message()
        )
    }
}
