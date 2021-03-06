//
//  UserUpdateRequest.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 09.05.2022.
//

import Foundation

struct UserUpdateRequestModel: Encodable {
    let firstName: String
    let secondName: String
    let userName: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case secondName = "second_name"
        case userName = "username"
        case password = "hashed_password"
    }
    
    init (
        firstName: String = "",
        secondName: String = "",
        userName: String,
        password: String
    ) {
        self.firstName = firstName
        self.secondName = secondName
        self.userName = userName
        self.password = password
    }
    
    init(_ user: User) {
        firstName = ""
        secondName = ""
        userName = user.userName
        password = user.password
    }
}

struct UserUpdateRequest: Request {
    let method: HTTP.Method = .put
    private(set) var path: String = "users/"
    let body: HTTP.Body
    let token: String
    
    init(_ model: UserUpdateRequestModel, _ id: Int, _ token: String) {
        self.token = token
        path += "\(id)"
        body = .model(model)
    }
}
