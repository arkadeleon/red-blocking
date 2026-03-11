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

    init(
        settings: AppSettings = AppSettings(),
        legacyAppController: LegacyAppController = .shared
    ) {
        self.settings = settings
        self.legacyAppController = legacyAppController

        settings.registerDefaults()
    }
}
