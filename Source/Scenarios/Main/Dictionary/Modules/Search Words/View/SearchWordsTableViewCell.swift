//
//  SearchWordsTableViewCell.swift
//  Find-and-Learn
//
//  Created by Руслан on 28.03.2022.
//

import UIKit

final class SearchWordsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = R.color.defaultBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with word: WordModel) {
        textLabel?.text = word.word
        detailTextLabel?.text = word.translations
    }
}
