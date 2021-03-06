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
    private let userManager: UserManagerProtocol
    private let tokensManager: TokensManagerProtocol
    
    // MARK: Init
    
    init(
        validationManager: ValidationManagerProtocol,
        networkManager: NetworkManagerProtocol,
        userManager: UserManagerProtocol,
        tokensManager: TokensManagerProtocol
    ) {
        self.validationManager = validationManager
        self.networkManager = networkManager
        self.userManager = userManager
        self.tokensManager = tokensManager
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
            networkManager.perform(
                request
            ) { [weak self] (resultData: Result<AuthorizationResponseModel, NetworkManagerError>) in
                switch resultData {
                case .success(let model):
                    self?.tokensManager.saveToken(model.getAsToken())
                   
                    let userRequest = GetUserRequest(email, model.getAsToken())
                    self?.networkManager
                        .perform(userRequest) { (resultResponse: Result<UserRequestModel, NetworkManagerError>) in
                            switch resultResponse {
                            case .success(let responseModel):
                                self?.userManager.saveUser(User(
                                    id: responseModel.id,
                                    email: email,
                                    userName: responseModel.username ?? "",
                                    password: password,
                                    state: .inactive
                                ))
                                self?.userManager.saveEmailCode(responseModel.emailCode)
                                result(.success)
                            case .failure(let error):
                                print(error.localizedDescription)
                                result(.emailTextField(R.string.localizable.validation_error_not_right_data()))
                            }
                        }
                case .failure:
                    result(.emailTextField(R.string.localizable.validation_error_not_right_data()))
                }
            }
        }
    }
}

private struct AuthorizationResponseModel: Decodable {
    let token: String
    let type: String
    
    func getAsToken() -> String {
        return "\(type) \(token)"
    }
}

private struct UserRequestModel: Decodable {
    let id: Int
    let username: String?
    let emailCode: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case emailCode = "email_confirmation_code"
    }
}
