//
//  AppModel.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Observation

@MainActor
@Observable
final class AppModel {
    let settings: AppSettings
    let legacyAppController: LegacyAppController
    let characterRepository: CharacterRepository
    let moveRepository: MoveRepository
    let motionRepository: MotionRepository

    init(
        settings: AppSettings = AppSettings(),
        legacyAppController: LegacyAppController = .shared,
        characterRepository: CharacterRepository = CharacterRepository(),
        moveRepository: MoveRepository = MoveRepository(),
        motionRepository: MotionRepository = MotionRepository()
    ) {
        self.settings = settings
        self.legacyAppController = legacyAppController
        self.characterRepository = characterRepository
        self.moveRepository = moveRepository
        self.motionRepository = motionRepository

        settings.registerDefaults()
    }
}
