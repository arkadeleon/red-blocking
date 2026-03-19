//
//  AppModel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Observation

@MainActor
@Observable
final class AppModel {
    let settings: AppSettings
    let moveRepository: MoveRepository
    let motionRepository: MotionRepository
    let navigation: AppNavigationModel
    let characterList: CharacterListModel

    init(
        settings: AppSettings? = nil,
        moveRepository: MoveRepository = MoveRepository(),
        motionRepository: MotionRepository = MotionRepository(),
        navigation: AppNavigationModel? = nil,
        characterList: CharacterListModel? = nil
    ) {
        let resolvedSettings = settings ?? .standard
        self.settings = resolvedSettings
        self.moveRepository = moveRepository
        self.motionRepository = motionRepository
        let resolvedNavigation = navigation ?? AppNavigationModel(
            moveRepository: moveRepository
        )
        self.navigation = resolvedNavigation
        self.characterList = characterList ?? CharacterListModel(
            navigation: resolvedNavigation
        )
    }
}
