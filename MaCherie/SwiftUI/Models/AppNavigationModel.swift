//
//  AppNavigationModel.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppNavigationModel {
    private let characterRepository: CharacterRepository
    private let moveRepository: MoveRepository

    private(set) var characters: [CharacterSelection] = []
    private(set) var currentRootNode: MoveNode?

    var sidebarErrorMessage: String?
    var selectedCharacter: CharacterSelection? {
        didSet {
            guard selectedCharacter?.id != oldValue?.id else {
                return
            }

            detailPath.removeAll()
            currentRootNode = selectedCharacter.map(makeRootNode(for:))

            if let selectedCharacter {
                loadRootSections(for: selectedCharacter)
            }
        }
    }

    var detailPath: [MoveDestination] = []

    private var nodeSections: [MoveNode.ID: [CharacterMove.Section]] = [:]
    private var nodeErrors: [MoveNode.ID: String] = [:]

    init(
        characterRepository: CharacterRepository = CharacterRepository(),
        moveRepository: MoveRepository = MoveRepository()
    ) {
        self.characterRepository = characterRepository
        self.moveRepository = moveRepository
        loadCharacters()
    }

    func loadCharacters() {
        do {
            let loadedCharacters = try characterRepository.loadCharacters().map(CharacterSelection.init)
            let previousSelectionID = selectedCharacter?.id

            characters = loadedCharacters
            sidebarErrorMessage = nil

            if let previousSelectionID {
                selectedCharacter = loadedCharacters.first { $0.id == previousSelectionID }
            } else {
                selectedCharacter = nil
            }
        } catch {
            characters = []
            selectedCharacter = nil
            currentRootNode = nil
            detailPath.removeAll()
            sidebarErrorMessage = "Failed to load the character list."
        }
    }

    func sections(for node: MoveNode) -> [CharacterMove.Section] {
        nodeSections[node.id] ?? []
    }

    func errorMessage(for node: MoveNode) -> String? {
        nodeErrors[node.id]
    }

    func pushNextNode(title: String, sections: [CharacterMove.Section]) {
        let node = MoveNode(id: "move:\(UUID().uuidString)", title: title)
        nodeSections[node.id] = sections
        nodeErrors[node.id] = nil
        detailPath.append(.moveNode(node))
    }

    func pushMotionPlayer(title: String, characterCode: String, skillCode: String) {
        detailPath.append(
            .motionPlayer(
                title: title,
                characterCode: characterCode,
                skillCode: skillCode
            )
        )
    }

    private func makeRootNode(for selection: CharacterSelection) -> MoveNode {
        MoveNode(id: "character:\(selection.id)", title: selection.title)
    }

    private func loadRootSections(for selection: CharacterSelection) {
        let node = makeRootNode(for: selection)

        do {
            nodeSections[node.id] = try moveRepository.loadSections(resourceName: selection.moveResourceName)
            nodeErrors[node.id] = nil
        } catch {
            nodeSections[node.id] = []
            nodeErrors[node.id] = "Failed to load moves for \(selection.title)."
        }
    }
}
