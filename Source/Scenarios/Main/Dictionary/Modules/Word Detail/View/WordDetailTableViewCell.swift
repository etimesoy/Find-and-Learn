//
//  WordDetailTableViewCell.swift
//  Find-and-Learn
//
//  Created by Руслан on 25.04.2022.
//

import UIKit

final class WordDetailTableViewCell: UITableViewCell {
    // MARK: UI
    
    private lazy var checkboxView: UIView = {
        let view = UIView()
        view.layer.borderWidth = .checkboxBorderWidth
        view.layer.borderColor = .checkboxBorderColor
        view.layer.backgroundColor = UIColor.checkboxPassiveColor.cgColor
        return view
    }()
    
    private lazy var translationLabel: UILabel = {
        let label = UILabel()
        label.setFontSize(.translationLabelFontSize)
        return label
    }()
    
    private lazy var examplesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = .examplesStackViewSpacing
        return stackView
    }()
    
    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorViewBackgroundColor
        return view
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorViewBackgroundColor
        return view
    }()
    
    // MARK: Properties
    
    var translationModel: TranslationModel?
    var bottomSeparatorViewIsHidden = false {
        didSet {
            bottomSeparatorView.isHidden = bottomSeparatorViewIsHidden
        }
    }
    
    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = R.color.defaultBackgroundColor()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI configuration
    
    private func configureSubviews() {
        addSubview(topSeparatorView)
        topSeparatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(Constants.separatorViewHeight)
        }
        
        addSubview(checkboxView)
        checkboxView.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.checkboxViewSize)
            make.leading.equalToSuperview().inset(Constants.standardInset)
        }
        
        addSubview(translationLabel)
        translationLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkboxView.snp.trailing).offset(Constants.standardInset)
            make.top.equalTo(topSeparatorView).inset(Constants.standardInset)
        }
        checkboxView.snp.makeConstraints { make in
            make.centerY.equalTo(translationLabel)
        }
        
        addSubview(examplesStackView)
        examplesStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Constants.standardInset * 2)
            make.top.equalTo(translationLabel.snp.bottom).offset(Constants.standardInset)
        }
        
        addSubview(bottomSeparatorView)
        bottomSeparatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(examplesStackView.snp.bottom).offset(Constants.standardInset)
            make.height.equalTo(Constants.separatorViewHeight)
        }
    }
    
    func configure(with translationModel: TranslationModel) {
        if self.translationModel == translationModel {
            return
        }
        self.translationModel = translationModel
        
        translationLabel.text = translationModel.translationWithSynonyms
        examplesStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        examplesStackView.addArrangedSubviews(translationModel.examples.map { exampleModel in
            var labelText = exampleModel.example
            if let translation = exampleModel.translation {
                labelText += " - " + translation
            }
            return TranslationExampleLabel(text: labelText)
        })
        let checkboxColor: UIColor? = translationModel.isSelected ? .checkboxActiveColor : .checkboxPassiveColor
        checkboxView.layer.backgroundColor = checkboxColor?.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
            let isSelected = translationModel?.isSelected {
            let checkboxColor: UIColor? = isSelected ? .checkboxActiveColor : .checkboxPassiveColor
            checkboxView.layer.backgroundColor = checkboxColor?.cgColor
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let checkboxBorderWidth: CGFloat = 2
    static let translationLabelFontSize: CGFloat = 18
    static let examplesStackViewSpacing: CGFloat = 4
}

private extension CGColor {
    static let checkboxBorderColor: CGColor = UIColor.lightGray.cgColor
}

private extension UIColor {
    static let checkboxActiveColor: UIColor? = R.color.buttonsBackgroundColor()
    static let checkboxPassiveColor: UIColor = .white
}

private extension UIColor {
    static let separatorViewBackgroundColor = UIColor(red: 190 / 255, green: 190 / 255, blue: 190 / 255, alpha: 1)
}

private enum Constants {
    static let separatorViewHeight = 2
    static let checkboxViewSize = 12
    static let standardInset = 8
}
