//
//  PreviewAppModel.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

@MainActor
enum PreviewAppModel {
    struct MotionPlayerPreviewConfiguration {
        let appModel: AppModel
        let title: String
        let characterCode: String
        let skillCode: String
    }

    static func rootNavigation() -> AppModel {
        let appModel = makeAppModel()
        loadInitialCharacter(into: appModel)
        return appModel
    }

    static func moveBrowser() -> (appModel: AppModel, node: MoveNode) {
        let appModel = rootNavigation()
        let node = appModel.navigation.currentRootNode ?? MoveNode(
            id: "preview:root",
            title: "Preview"
        )
        return (appModel, node)
    }

    static func motionPlayer() -> MotionPlayerPreviewConfiguration? {
        let appModel = rootNavigation()
        guard
            let rootNode = appModel.navigation.currentRootNode,
            let playableMove = firstPlayableMove(in: appModel.navigation.sections(for: rootNode))
        else {
            return nil
        }

        return MotionPlayerPreviewConfiguration(
            appModel: appModel,
            title: playableMove.skillName,
            characterCode: playableMove.characterCode,
            skillCode: playableMove.skillCode
        )
    }

    private static func makeAppModel() -> AppModel {
        AppModel(settings: AppSettings(userDefaults: makePreviewUserDefaults()))
    }

    private static func makePreviewUserDefaults() -> UserDefaults {
        let suiteName = "com.github.arkadeleon.ma-cherie.preview"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return .standard
        }

        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }

    private static func loadInitialCharacter(into appModel: AppModel) {
        guard let selection = appModel.characterList.characters.first else {
            return
        }

        appModel.characterList.selectedCharacter = selection
    }

    private static func firstPlayableMove(in sections: [CharacterMove.Section]) -> CharacterMove.Frames? {
        for section in sections {
            for move in section.rows {
                if let presented = move.presented, presented.viewController == "FramesPlayerViewController" {
                    return presented
                }

                if let next = move.next, let nestedMove = firstPlayableMove(in: next) {
                    return nestedMove
                }
            }
        }

        return nil
    }
}
