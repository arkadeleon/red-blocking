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
            currentRootNode = nil
            currentProfile = nil
            currentProfileErrorMessage = nil

            if let selectedCharacter {
                loadCurrentProfile(for: selectedCharacter)
            }
        }
    }

    var detailPath: [MoveDestination] = []

    init(
        moveRepository: MoveRepository = MoveRepository()
    ) {
        self.moveRepository = moveRepository
    }

    func pushNode(_ node: MoveNode) {
        detailPath.append(.moveNode(node))
    }

    func pushMotionPlayer(_ link: MoveBrowserAction.MotionPlayerLink) {
        detailPath.append(.motionPlayer(link))
    }

    func showCharacter(_ selection: CharacterSelection?) {
        selectedCharacter = selection
    }

    private func loadCurrentProfile(for selection: CharacterSelection) {
        do {
            let profile = try moveRepository.loadProfile(resourceName: selection.moveResourceName)
            currentProfile = profile
            currentRootNode = .profile(profile)
            currentProfileErrorMessage = nil
        } catch {
            currentProfile = nil
            currentRootNode = nil
            currentProfileErrorMessage = error.localizedDescription
        }
    }
}
