//
//  CharacterListModel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class CharacterListModel {
    private let rosterLayout = CharacterRosterLayout.streetFighterIIIThirdStrike
    private let characterRepository: CharacterRepository
    private let navigation: AppNavigationModel

    private(set) var characters: [CharacterSelection] = []
    var errorMessage: String?
    var selectedCharacter: CharacterSelection? {
        didSet {
            guard selectedCharacter?.id != oldValue?.id else {
                return
            }

            navigation.showCharacter(selectedCharacter)
        }
    }

    init(
        characterRepository: CharacterRepository = CharacterRepository(),
        navigation: AppNavigationModel
    ) {
        self.characterRepository = characterRepository
        self.navigation = navigation
        loadCharacters()
    }

    func loadCharacters() {
        do {
            let loadedCharacters = try characterRepository.loadCharacters().map(CharacterSelection.init)
            let previousSelectionID = selectedCharacter?.id

            characters = loadedCharacters
            errorMessage = nil

            if let previousSelectionID {
                selectedCharacter = loadedCharacters.first { $0.id == previousSelectionID }
            } else {
                selectedCharacter = nil
            }
        } catch {
            characters = []
            errorMessage = "Failed to load the character list."
            selectedCharacter = nil
        }
    }

    func applyDefaultSelectionIfNeeded(for horizontalSizeClass: UserInterfaceSizeClass?) {
        guard horizontalSizeClass == .regular, selectedCharacter == nil else {
            return
        }

        selectedCharacter = rosterLayout.defaultCharacter(from: characters)
    }
}
