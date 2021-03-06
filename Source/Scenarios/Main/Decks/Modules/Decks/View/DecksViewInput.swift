//
//  DecksViewInput.swift
//  Find-and-Learn
//
//  Created by Руслан on 03.05.2022.
//

import Foundation

protocol DecksViewInput: AnyObject {
    func showDecks(_ models: [Deck])
    func appendDeck(_ model: Deck)
    func setAlertActionIsEnabled(_ isEnabled: Bool)
}
