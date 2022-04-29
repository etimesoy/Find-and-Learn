//
//  AchievementsPresenter.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 29.04.2022.
//

import Foundation

protocol AchievementsViewOutput: AnyObject {
    func viewDidLoad()
}

final class AchievementsPresenter: AchievementsViewOutput {
    // MARK: Dependencies

    weak var view: AchievementsViewInput?
    
    // MARK: AchievementsViewOutput
    
    func viewDidLoad() {
    }
}
