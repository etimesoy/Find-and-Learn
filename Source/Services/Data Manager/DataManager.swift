//
//  DataManager.swift
//  Find-and-Learn
//
//  Created by Руслан on 31.03.2022.
//

import CoreData

final class DataManager: DataManagerProtocol {
    // MARK: Singleton
    
    static let shared: DataManagerProtocol = DataManager()
    
    private init() {}
    
    // MARK: KeyChain
    
    private let backendTokenKeyChainKey = "backendTokenKeyChainKey"
    
    // MARK: Core Data
    
    private let queue = DispatchQueue(label: "CoreDataSerialQueue")
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Find_and_Learn")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    private lazy var viewContext = persistentContainer.viewContext
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Private methods

private extension DataManager {
    func checkId(_ objectId: Int, entityType: NSManagedObject.Type) -> Bool {
        let fetchRequest = entityType.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", objectId)
        let object = try? viewContext.fetch(fetchRequest).first
        return object == nil
    }
}

// MARK: - Public methods

extension DataManager {
    func getWords(_ wordPart: String, completion: ([Word]) -> Void) {
        queue.sync {
            let fetchRequest = WordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word CONTAINS[c] %@", wordPart)
            do {
                let wordsEntities = try viewContext.fetch(fetchRequest)
                completion(wordsEntities.map { Word($0) })
            } catch {
                completion([])
            }
        }
    }
    
    func saveWord(_ word: Word) {
        queue.sync {
            let fetchRequest = WordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word == %@", word.word)
            if (try? viewContext.fetch(fetchRequest).first) != nil { return }
            
            let wordEntity = WordEntity(context: viewContext, word: word.word)
            wordEntity.translations = Set(word.detailTranslations?.map { translation in
                let translationId = checkId(
                    translation.id, entityType: TranslationEntity.self
                ) ? translation.id : Int.random(in: 1...1_000_000)
                let translationEntity = TranslationEntity(
                    context: viewContext,
                    transcription: translation.transcription,
                    speechPart: translation.speechPart,
                    translation: translation.translation,
                    id: translationId,
                    word: wordEntity
                )
                translationEntity.examples = Set(translation.examples.map { example in
                    let exampleId = checkId(
                        example.id, entityType: ExampleEntity.self
                    ) ? example.id : Int.random(in: 1...1_000_000)
                    return ExampleEntity(
                        context: viewContext,
                        id: exampleId,
                        translationId: translationId,
                        example: example.example,
                        exampleTranslation: example.translation,
                        translation: translationEntity
                    )
                })
                return translationEntity
            } ?? [])
            
            saveContext()
        }
    }
    
    func fetchHistoryWords(completion: ([HistoryWord]) -> Void) {
        queue.sync {
            let fetchRequest = HistoryWordEntity.fetchRequest()
            do {
                let historyWordsEntities = try viewContext.fetch(fetchRequest)
                completion(historyWordsEntities.map { historyWordEntity in
                    HistoryWord(
                        word: historyWordEntity.word.word,
                        translations: historyWordEntity.word.translations.map { $0.translation },
                        dateAdded: historyWordEntity.timeOpened
                    )
                })
            } catch {
                completion([])
            }
        }
    }
    
    func addHistoryWord(wordId: Int, timeOpened: Date, completion: ((Bool) -> Void)?) {
        queue.sync {
            let fetchRequest = WordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", wordId)
            if let wordEntity = try? viewContext.fetch(fetchRequest).first {
                _ = HistoryWordEntity(
                    context: viewContext,
                    wordId: wordId,
                    timeOpened: timeOpened,
                    word: wordEntity
                )
                saveContext()
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func fetchFavoriteWords(completion: ([Word]) -> Void) {
        queue.sync {
            let fetchRequest = WordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isFavorite == %c", true)
            do {
                let wordsEntities = try viewContext.fetch(fetchRequest)
                completion(wordsEntities.map { Word($0) })
            } catch {
                completion([])
            }
        }
    }
    
    func fetchWordDetail(_ word: String, completion: @escaping (WordDetail?) -> Void) {
        queue.sync {
            let fetchRequest = WordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word == %@", word)
            let wordEntity = try? viewContext.fetch(fetchRequest).first
            completion(wordEntity.map { WordDetail($0) })
        }
    }
    
    func changeWordStatus(_ wordId: Int, isFavorite: Bool) {
        queue.sync {
            let fetchRequest = WordEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", wordId)
            let wordEntity = try? viewContext.fetch(fetchRequest).first
            wordEntity?.isFavorite = isFavorite
            saveContext()
        }
    }
    
    func fetchDecks(includeFlashcards: Bool, completion: @escaping ([Deck]) -> Void) {
        queue.sync {
            let fetchRequest = DeckEntity.fetchRequest()
            do {
                let decksEntities = try viewContext.fetch(fetchRequest)
                completion(decksEntities.map {
                    Deck(
                        id: Int($0.id),
                        name: $0.name,
                        createdAt: $0.createdAt,
                        flashcards: includeFlashcards ? $0.flashcards.map { Flashcard($0) } : nil
                    )
                })
            } catch {
                completion([])
            }
        }
    }
    
    func saveNewFlashcard(_ newFlashcard: NewFlashcard, completion: ((Bool) -> Void)?) {
        queue.sync {
            let fetchRequest = DeckEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", newFlashcard.deckId)
            if let deckEntity = try? viewContext.fetch(fetchRequest).first {
                _ = FlashcardEntity(
                    context: viewContext,
                    comment: newFlashcard.comment,
                    backSide: newFlashcard.backSide,
                    frontSide: newFlashcard.frontSide,
                    deckId: newFlashcard.deckId,
                    deck: deckEntity
                )
                if newFlashcard.createReversed {
                    _ = FlashcardEntity(
                        context: viewContext,
                        comment: newFlashcard.comment,
                        backSide: newFlashcard.frontSide,
                        frontSide: newFlashcard.backSide,
                        deckId: newFlashcard.deckId,
                        deck: deckEntity
                    )
                }
                saveContext()
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func deleteDeck(deckId: Int) {
        queue.sync {
            let fetchRequest = DeckEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", deckId)
            if let deckEntity = try? viewContext.fetch(fetchRequest).first {
                viewContext.delete(deckEntity)
                saveContext()
            }
        }
    }
    
    func createDeck(name: String, completion: @escaping (Deck) -> Void) {
        queue.sync {
            let deckEntity = DeckEntity(context: viewContext, name: name)
            saveContext()
            completion(Deck(
                id: Int(deckEntity.id),
                name: deckEntity.name,
                createdAt: deckEntity.createdAt,
                flashcards: deckEntity.flashcards.map { Flashcard($0) }
            ))
        }
    }
    
    func deleteFlashcard(flashcardId: Int) {
        queue.sync {
            let fetchRequest = FlashcardEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", flashcardId)
            if let flashcardEntity = try? viewContext.fetch(fetchRequest).first {
                viewContext.delete(flashcardEntity)
                saveContext()
            }
        }
    }
    
    func fetchFlashcards(deckId: Int, completion: @escaping ([Flashcard]?) -> Void) {
        queue.sync {
            let fetchRequest = DeckEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", deckId)
            let deckEntity = try? viewContext.fetch(fetchRequest).first
            completion(deckEntity?.flashcards.map { Flashcard($0) })
        }
    }
    
    func updateFlashcard(_ flashcard: Flashcard, updatedDeckId: Int) {
        queue.sync {
            let flashcardFetchRequest = FlashcardEntity.fetchRequest()
            flashcardFetchRequest.predicate = NSPredicate(format: "id == %ld", flashcard.id)
            guard let flashcardEntity = try? viewContext.fetch(flashcardFetchRequest).first else {
                return
            }
            
            flashcardEntity.comment = flashcard.comment
            flashcardEntity.backSide = flashcard.backSide
            flashcardEntity.frontSide = flashcard.frontSide
            
            let oldDeckFetchRequest = DeckEntity.fetchRequest()
            oldDeckFetchRequest.predicate = NSPredicate(format: "id == %ld", flashcardEntity.deckId)
            let oldDeckEntity = try? viewContext.fetch(oldDeckFetchRequest).first
            oldDeckEntity?.flashcards.remove(flashcardEntity)
            
            let updatedDeckFetchRequest = DeckEntity.fetchRequest()
            updatedDeckFetchRequest.predicate = NSPredicate(format: "id == %ld", updatedDeckId)
            let updatedDeckEntity = try? viewContext.fetch(updatedDeckFetchRequest).first
            updatedDeckEntity?.addToFlashcards(flashcardEntity)
            
            saveContext()
        }
    }
    
    func saveToken(_ token: String) {
        KeyChainManager.save(key: backendTokenKeyChainKey, data: Data(from: token))
    }
    
    func getToken() -> String? {
        return KeyChainManager.load(key: backendTokenKeyChainKey)?.to(type: String.self)
    }
    
    func removeToken() {
        KeyChainManager.remove(key: backendTokenKeyChainKey)
    }
    
    func getApiKey() -> String? {
        return "dict.1.1.20220509T162427Z.6fc4e65140e1e3dc.6be551b61e08e1351dce814bb39a1f6e6fb58573"
    }
}
