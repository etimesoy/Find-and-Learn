//
//  AccountInteractor.swift
//  Find-and-Learn
//
//  Created by Роман Сницарюк on 08.04.2022.
//

import Foundation
import UIKit

protocol AccountInteractorProtocol: AnyObject {
    func loadSettings() -> UserSettings
    func deleteAccount(_ completion: @escaping (Bool) -> Void)
    func deleteUserInfo()
    func changeUserName(_ userName: String)
    func downloadPopularWords(_ completion: @escaping () -> Void)
    func saveAvatarImage(_ image: UIImage)
}

final class AccountInteractor: AccountInteractorProtocol {
    // MARK: Dependencies
    
    private let tokensManager: TokensManagerProtocol
    private let settingsManager: SettingsManagerProtocol
    private let userManager: UserManagerProtocol
    private let networkManager: NetworkManagerProtocol
    private let wordsRepository: WordsRepositoryProtocol
    private let decksRepository: DecksRepositoryProtocol
    private let filesManager: FilesManagerProtocol
    private let achievementsManager: AchievementsManagerProtocol
    
    private typealias DownloadWordsResponseModel = Result<[PopularWordResponseModel], NetworkManagerError>
    
    // MARK: Init
    
    init(
        tokensManager: TokensManagerProtocol,
        settingsManager: SettingsManagerProtocol,
        userManager: UserManagerProtocol,
        networkManager: NetworkManagerProtocol,
        wordsRepository: WordsRepositoryProtocol,
        decksRepository: DecksRepositoryProtocol,
        filesManager: FilesManagerProtocol,
        achievementsManager: AchievementsManagerProtocol
    ) {
        self.tokensManager = tokensManager
        self.settingsManager = settingsManager
        self.userManager = userManager
        self.networkManager = networkManager
        self.wordsRepository = wordsRepository
        self.decksRepository = decksRepository
        self.filesManager = filesManager
        self.achievementsManager = achievementsManager
    }
    
    // MARK: AccountInteractorProtocol
    
    func loadSettings() -> UserSettings {
        let user = userManager.getUser()
        let didDownloadDictionary = userManager.didDownloadDictionary()
        let settings = settingsManager.getSettingsByState(user.state, includeDownloadDictionary: !didDownloadDictionary)
        let avatarImage = filesManager.getAvatar()
        return UserSettings(settings: settings, userName: user.userName, avatarImage: avatarImage)
    }
    
    func deleteAccount(_ completion: @escaping (Bool) -> Void) {
        let user = userManager.getUser()
        guard let token = tokensManager.getToken() else {
            return
        }
        let request = DeleteRequest(user.id, token)
        networkManager.perform(request) { [weak self] result in
            switch result {
            case .success:
                self?.deleteUserInfo()
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    func deleteUserInfo() {
        tokensManager.removeToken()
        userManager.deleteAllUserInfo()
        wordsRepository.deleteHistoryWords()
        wordsRepository.deleteFavoriteWords()
        decksRepository.deleteDecks()
        filesManager.deleteAvatar()
        achievementsManager.deleteAchievements()
    }
    
    func changeUserName(_ userName: String) {
        let user = userManager.updateUserName(userName)
        guard let token = tokensManager.getToken() else {
            return
        }
        let request = UserUpdateRequest(.init(user), user.id, token)
        networkManager.perform(request) { _ in
        }
    }
    
    func downloadPopularWords(_ completion: @escaping () -> Void) {
        guard let token = tokensManager.getToken() else { return }
        let request = PopularWordsRequest(token)
        
        networkManager.perform(request) { [weak self] (result: DownloadWordsResponseModel) in
            switch result {
            case .success(let models):
                models.map { popularWord in
                    Word(
                        word: popularWord.text,
                        detailTranslations: popularWord.definitions.flatMap { popularDefinition -> [Translation] in
                            guard let speechPart = popularDefinition.speechPart else { return [] }
                            return popularDefinition.translations.map { popularTranslation in
                                Translation(
                                    id: Int.random(in: 1...1_000_000),
                                    translation: popularTranslation.text,
                                    speechPart: speechPart,
                                    transcription: popularDefinition.transcription,
                                    examples: popularTranslation.examples.map { popularExample in
                                        Example(
                                            id: Int.random(in: 1...1_000_000),
                                            example: popularExample.text,
                                            translation: popularExample.translations.joined(separator: ", ")
                                        )
                                    }
                                )
                            }
                        }
                    )
                }
                .forEach {
                    self?.wordsRepository.saveWord($0)
                }
                self?.userManager.setDidDownloadDictionary(true)
            case .failure(let error):
                assertionFailure(error.localizedDescription.debugDescription)
            }
            completion()
        }
    }
    
    func saveAvatarImage(_ image: UIImage) {
        filesManager.saveAvatar(image)
    }
}

private struct PopularWordResponseModel: Decodable {
    let text: String
    let definitions: [PopularDefinitionResponseModel]
}

private struct PopularDefinitionResponseModel: Decodable {
    let speechPart: String?
    let transcription: String?
    let translations: [PopularTranslationResponseModel]
    
    enum CodingKeys: String, CodingKey {
        case speechPart = "speech_part"
        case transcription
        case translations
    }
}

private struct PopularTranslationResponseModel: Decodable {
    let text: String
    let examples: [PopularExampleResponseModel]
}

private struct PopularExampleResponseModel: Decodable {
    let text: String
    let translations: [String]
    
    enum CodingKeys: String, CodingKey {
        case text
        case translations = "example_translations"
    }
}
