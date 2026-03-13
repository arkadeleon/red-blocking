//
//  AppNavigationModel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppNavigationModel {
    private let moveRepository: MoveRepository

    private(set) var currentRootNode: MoveNode?
    private(set) var currentProfile: CharacterProfile?
    private(set) var currentProfileErrorMessage: String?
    private(set) var selectedCharacter: CharacterSelection? {
        didSet {
            guard selectedCharacter?.id != oldValue?.id else {
                return
            }

            detailPath.removeAll()
            currentRootNode = selectedCharacter.map(makeRootNode(for:))
            currentProfile = nil
            currentProfileErrorMessage = nil

            if let selectedCharacter {
                loadCurrentProfile(for: selectedCharacter)
                loadRootSections(for: selectedCharacter)
            }
        }
    }

    var detailPath: [MoveDestination] = []

    private var nodeSections: [MoveNode.ID: [CharacterMove.Section]] = [:]
    private var nodeErrors: [MoveNode.ID: String] = [:]

    init(
        moveRepository: MoveRepository = MoveRepository()
    ) {
        self.moveRepository = moveRepository
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

    func showCharacter(_ selection: CharacterSelection?) {
        selectedCharacter = selection
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
            nodeErrors[node.id] = "Couldn't load moves for \(selection.title)."
        }
    }

    private func loadCurrentProfile(for selection: CharacterSelection) {
        do {
            currentProfile = try moveRepository.loadProfile(resourceName: selection.moveResourceName)
            currentProfileErrorMessage = nil
        } catch {
            currentProfile = nil
            currentProfileErrorMessage = error.localizedDescription
        }
    }
}
