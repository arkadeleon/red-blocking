//
//  PreviewAppModel.swift
//  RedBlocking
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
        guard let node = appModel.navigation.currentRootNode else {
            preconditionFailure("Couldn't build a move browser preview without a root node.")
        }

        return (appModel, node)
    }

    static func motionPlayer() -> MotionPlayerPreviewConfiguration? {
        let appModel = rootNavigation()
        let browserProjector = MoveBrowserProjector()

        guard
            let rootNode = appModel.navigation.currentRootNode,
            let playableMove = firstPlayableMove(
                in: browserProjector.project(rootNode),
                browserProjector: browserProjector
            )
        else {
            return nil
        }

        return MotionPlayerPreviewConfiguration(
            appModel: appModel,
            title: playableMove.title,
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

    private static func firstPlayableMove(
        in page: MoveBrowserPage,
        browserProjector: MoveBrowserProjector
    ) -> MoveBrowserAction.MotionPlayerLink? {
        for section in page.sections {
            for row in section.rows {
                if let link = row.action.motionPlayerLink {
                    return link
                }

                if let nextNode = row.action.node,
                   let nestedMove = firstPlayableMove(
                       in: browserProjector.project(nextNode),
                       browserProjector: browserProjector
                   ) {
                    return nestedMove
                }
            }
        }

        return nil
    }
}
