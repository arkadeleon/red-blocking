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
    struct MoveBrowserModelPreviewConfiguration {
        let appModel: AppModel
        let node: MoveNode
        let model: MoveBrowserModel
    }

    struct MotionPlayerPreviewConfiguration {
        let appModel: AppModel
        let title: String
        let characterCode: String
        let skillCode: String
    }

    struct MotionPlayerLoadedPreviewConfiguration {
        let appModel: AppModel
        let motionData: MotionPlaybackData
        let playerModel: MotionPlayerModel
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

    static func moveBrowserModel() -> MoveBrowserModelPreviewConfiguration {
        let preview = moveBrowser()
        let model = MoveBrowserModel(
            node: preview.node,
            navigation: preview.appModel.navigation
        )

        return MoveBrowserModelPreviewConfiguration(
            appModel: preview.appModel,
            node: preview.node,
            model: model
        )
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

    static func motionPlayerLoaded() -> MotionPlayerLoadedPreviewConfiguration? {
        guard let preview = motionPlayer() else {
            return nil
        }

        do {
            let motionData = try preview.appModel.motionRepository.prepareMotion(
                characterCode: preview.characterCode,
                skillCode: preview.skillCode
            )
            let playerModel = MotionPlayerModel(
                motionData: motionData,
                playbackSettings: preview.appModel.settings.playback
            )

            if motionData.frameCount > 1 {
                playerModel.seek(to: 1)
            }

            return MotionPlayerLoadedPreviewConfiguration(
                appModel: preview.appModel,
                motionData: motionData,
                playerModel: playerModel
            )
        } catch {
            return nil
        }
    }

    static func characterSelection(_ character: Character = .ken) -> CharacterSelection {
        CharacterSelection(character: character)
    }

    static func characterSelections() -> [CharacterSelection] {
        Character.allCases.map(CharacterSelection.init)
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
