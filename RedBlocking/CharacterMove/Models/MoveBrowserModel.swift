//
//  MoveBrowserModel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Observation

@MainActor
@Observable
final class MoveBrowserModel {
    let node: MoveNode
    let sections: [CharacterMove.Section]
    let errorMessage: String?

    private let navigation: AppNavigationModel

    init(node: MoveNode, navigation: AppNavigationModel) {
        self.node = node
        self.navigation = navigation
        sections = navigation.sections(for: node)
        errorMessage = navigation.errorMessage(for: node)
    }

    func open(_ move: CharacterMove) {
        if let next = move.next {
            navigation.pushNextNode(
                title: title(for: move),
                sections: next
            )
        } else if let presented = move.presented, supportsMotionPlayer(presented) {
            navigation.pushMotionPlayer(
                title: title(for: move),
                characterCode: presented.characterCode,
                skillCode: presented.skillCode
            )
        }
    }

    func title(for move: CharacterMove) -> String {
        if let rowTitle = move.rowTitle, rowTitle.isEmpty == false {
            return rowTitle
        }

        if let presented = move.presented {
            return presented.skillName
        }

        return "Untitled"
    }

    func subtitle(for move: CharacterMove) -> String? {
        move.rowDetail
    }

    func playerSubtitle(for move: CharacterMove) -> String? {
        guard let presented = move.presented else {
            return nil
        }

        let title = title(for: move)
        if title != presented.skillName {
            return presented.skillName
        }

        return nil
    }

    func isMovePlayerEntry(_ move: CharacterMove) -> Bool {
        guard let presented = move.presented else {
            return false
        }

        return supportsMotionPlayer(presented)
    }

    private func supportsMotionPlayer(_ presented: CharacterMove.Frames) -> Bool {
        presented.viewController == "FramesPlayerViewController"
    }
}
