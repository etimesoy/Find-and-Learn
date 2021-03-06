//
//  AuthorizationViewInput.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 25.03.2022.
//

import Foundation

protocol AuthorizationViewInput: AnyObject {
    func showError(_ error: AuthorizationErrors)
    func showServerProblemsAlert()
    func startLoader()
    func stopLoader()
}
