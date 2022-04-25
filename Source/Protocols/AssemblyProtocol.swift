//
//  AssemblyProtocol.swift
//  Find-and-Learn
//
//  Created by Руслан on 31.03.2022.
//

import Foundation
import UIKit

protocol AssemblyProtocol: AnyObject {
    static func assemble() -> UIViewController
}

protocol TransitionAssemblyProtocol: AnyObject {
    associatedtype DataModel
    
    static func assemble(with model: DataModel) -> UIViewController
}
