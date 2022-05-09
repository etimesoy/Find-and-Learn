//
//  AuthorizationInteractor.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 05.04.2022.
//

import Foundation

protocol AuthorizationInteractorProtocol: AnyObject {
    func enter(email: String, password: String, _ result: @escaping (AuthorizationResultState) -> Void)
}

final class AuthorizationInteractor: AuthorizationInteractorProtocol {
    // MARK: Dependencies
    
    private let validationManager: ValidationManagerProtocol
    private let networkManager: NetworkManagerProtocol
    private let dataManager: DataManagerProtocol
    
    // MARK: Init
    
    init(
        validationManager: ValidationManagerProtocol,
        networkManager: NetworkManagerProtocol,
        dataManager: DataManagerProtocol
    ) {
        self.validationManager = validationManager
        self.networkManager = networkManager
        self.dataManager = dataManager
    }
    
    // MARK: AuthorizationInteractorProtocol
    
    func enter(email: String, password: String, _ result: @escaping (AuthorizationResultState) -> Void) {
        guard !email.isEmpty else {
            result(.emailTextField(R.string.localizable.validation_error_empty_email()))
            return
        }
        
        if !validationManager.isValidEmail(email) {
            result(.emailTextField(R.string.localizable.validation_error_incorrect_email()))
        } else if !validationManager.isValidPassword(password) {
            result(.passwordTextField(R.string.localizable.validation_error_incorrect_password()))
        } else {
            let request = AuthorizationRequest(.init(email: email, password: password))
            networkManager.perform(request) { (resultData: Result<AuthorizationResponseModel, Error>) in
                switch resultData {
                case .success(let model):
                    self.dataManager.saveToken("\(model.type) \(model.token)")
                   
                    let userRequest = UserRequest(email, "\(model.type) \(model.token)")
                    self.networkManager.perform(userRequest) { (resultResponse: Result<UserRequestModel, Error>) in
                        switch resultResponse {
                        case .success(let responseModel):
                            self.dataManager.saveUser(User(
                                email: email,
                                userName: responseModel.username ?? "",
                                password: "",
                                state: .inactive))
                            result(.success)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                case .failure(_):
                    result(.emailTextField(R.string.localizable.validation_error_not_right_data()))
                }
            }
        }
    }
}

private struct AuthorizationResponseModel: Decodable {
    let token: String
    let type: String
}

private struct UserRequestModel: Decodable {
    let username: String?
    let emailCode: Int
    
    enum CodingKeys: String, CodingKey {
        case username
        case emailCode = "email_confirmation_code"
    }
}
