//
//  ValidationManagerProtocol.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 03.04.2022.
//

import Foundation

protocol ValidationManagerProtocol {
    func isValidEmail(_ email: String) -> Bool
    func isValidPassword(_ password: String) -> Bool
    func isValidUserName(_ userName: String) -> Bool
}