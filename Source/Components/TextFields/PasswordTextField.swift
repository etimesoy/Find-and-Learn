//
//  PasswordTextField.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 26.03.2022.
//

import Foundation
import UIKit

final class PasswordTextField: UITextField {
    // MARK: Properties
    
    private let closedEyeImage = UIImage(resource: R.image.closed_eye)
    private let openedEyeImage = UIImage(resource: R.image.opened_eye)
        
    // MARK: Init
    
    init(placeholder: String?, layerColor: CGColor?) {
        super.init(frame: .zero)
        initialize(placeholder: placeholder, layerColor: layerColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }
    
    // MARK: Private
    
    private func initialize(placeholder: String?, layerColor: CGColor?) {
        self.placeholder = placeholder
        textContentType = .oneTimeCode
        adjustsFontSizeToFitWidth = true
        minimumFontSize = .minimumFontSize
        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
        if let layerColor = layerColor {
            layer.borderWidth = .borderWidth
            layer.borderColor = layerColor
            layer.cornerRadius = .cornerRounding
        }
        
        isSecureTextEntry = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: .eyeImageSize, height: .eyeImageSize))
        button.setImage(openedEyeImage, for: .normal)
        button.setImage(closedEyeImage, for: .selected)
        button.tintColor = R.color.passwordEyeColor()
        button.imageEdgeInsets = Constants.imagePadding
        button.addTarget(self, action: #selector(showHidePassword(_:)), for: .touchUpInside)
        
        rightView = button
        rightViewMode = .always
    }
    
    @objc private func showHidePassword(_ sender: UIButton) {
        sender.isSelected.toggle()
        isSecureTextEntry = !sender.isSelected
    }
    
    // MARK: Override
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Constants.padding)
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Constants.padding)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Constants.padding)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRounding: CGFloat = 15
        
    static let borderWidth: CGFloat = 1
    
    static let eyeImageSize: CGFloat = 20
    static let minimumFontSize: CGFloat = 10
}

private extension PasswordTextField {
    enum Constants {
        static let padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 40)
        
        static let imagePadding = UIEdgeInsets(top: 8, left: 6, bottom: 4, right: 6)
    }
}
