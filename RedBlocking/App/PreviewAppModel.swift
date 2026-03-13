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

    static func moveBrowser() -> (appModel: AppModel, page: MoveBrowserPage) {
        let appModel = rootNavigation()
        let page = appModel.navigation.currentRootPage ?? MoveBrowserPage(
            id: "preview:root",
            navigationTitle: "Preview",
            sections: []
        )
        return (appModel, page)
    }

    static func motionPlayer() -> MotionPlayerPreviewConfiguration? {
        let appModel = rootNavigation()
        guard
            let rootPage = appModel.navigation.currentRootPage,
            let playableMove = firstPlayableMove(in: rootPage)
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

    private static func firstPlayableMove(in page: MoveBrowserPage) -> MoveBrowserAction.MotionPlayerLink? {
        for section in page.sections {
            for row in section.rows {
                if let link = row.action.motionPlayerLink {
                    return link
                }

                if let nextPage = row.action.page, let nestedMove = firstPlayableMove(in: nextPage) {
                    return nestedMove
                }
            }
        }

        return nil
    }
}
