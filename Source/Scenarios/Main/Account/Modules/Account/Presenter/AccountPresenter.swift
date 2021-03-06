//
//  AccountPresenter.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 02.04.2022.
//

import Foundation
import UIKit

final class AccountPresenter: AccountViewOutput {
    // MARK: Dependencies
    
    weak var view: AccountViewInput?
    private let interactor: AccountInteractorProtocol
    private let router: AccountRouterProtocol
    
    // MARK: Init & deinit
    
    init(interactor: AccountInteractorProtocol, router: AccountRouterProtocol) {
        self.interactor = interactor
        self.router = router
        NotificationCenter.default.addObserver(
            self, selector: #selector(loadSettings), name: .didConfirmEmail, object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didConfirmEmail, object: nil)
    }
    
    // MARK: ViewOutput
    
    func viewDidLoad() {
        loadSettings()
    }
    
    func changeUserName(for userName: String) {
        interactor.changeUserName(userName)
    }
    
    func changeAvatar(for avatar: UIImage) {
        interactor.saveAvatarImage(avatar)
    }
    
    func settingsTapped(with type: SettingType) {
        switch type {
        case .confirmEmail:
            showConfirmEmail()
        case .showAchievements:
            showAchievements()
        case .changePassword:
            showChangePassword()
        case .downloadDictionary:
            view?.askForDownloadingDictionary()
        case .exit:
            view?.askForExit()
        case .deleteAccount:
            view?.askForDeletingAccount()
        case .registration:
            showRegistration()
        }
    }
    
    func downloadDictionary() {
        view?.showDictionaryDownloadingStarted()
        interactor.downloadPopularWords { [weak self] in
            self?.view?.showDictionaryDownloadingEnded()
        }
    }
    
    func exit() {
        interactor.deleteUserInfo()
        router.showEntranceFlow()
    }
    
    func deleteAccount() {
        interactor.deleteAccount { [weak self] result in
            if result {
                self?.router.showEntranceFlow()
            } else {
                self?.view?.showServerProblemsAlert()
            }
        }
    }
    
    // MARK: Private
    
    @objc private func loadSettings() {
        let userSettings = interactor.loadSettings()
        view?.setup(with: userSettings)
    }
    
    private func showConfirmEmail() {
        router.showConfirmEmailModule()
    }
    
    private func showAchievements() {
        router.showAchievementsModule()
    }
    
    private func showChangePassword() {
        router.showChangePasswordModule()
    }
    
    private func showRegistration() {
        router.showRegistrationModule()
    }
}
