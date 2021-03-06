//
//  AccountTableViewCell.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 02.04.2022.
//

import UIKit

final class AccountTableViewCell: UITableViewCell {
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = R.color.defaultBackgroundColor()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure
    
    func configure(with settings: Setting) {
        textLabel?.text = settings.name
    }
    
    // MARK: Private
    
    private func setupView() {
        textLabel?.textAlignment = .center
    }
}
