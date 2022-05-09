//
//  HTTP.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 07.05.2022.
//

import Foundation

enum HTTP {
    struct AnyEncodable: Encodable {
        private let encodable: Encodable

        public init(_ encodable: Encodable) {
            self.encodable = encodable
        }

        func encode(to encoder: Encoder) throws {
            try encodable.encode(to: encoder)
        }
    }
    
    typealias Queries = [String: CustomStringConvertible]
   
    enum Body {
        case raw(Data)
        case model(AnyEncodable)
        case keyValue([String: Any])
    }
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
    }
    
    enum Errors: Error {
        case incorrectUrl(String)
    }
}
