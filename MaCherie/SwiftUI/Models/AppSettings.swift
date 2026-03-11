//
//  AppSettings.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func registerDefaults() {
        userDefaults.register(defaults: defaultValues)
    }

    private var defaultValues: [String: Any] {
        [
            Player1PassiveHitboxHiddenKey: false,
            Player1OtherVulnerabilityHitboxHiddenKey: false,
            Player1ActiveHitboxHiddenKey: false,
            Player1ThrowHitboxHiddenKey: false,
            Player1ThrowableHitboxHiddenKey: false,
            Player1PushHitboxHiddenKey: false,
            Player2PassiveHitboxHiddenKey: true,
            Player2OtherVulnerabilityHitboxHiddenKey: true,
            Player2ActiveHitboxHiddenKey: true,
            Player2ThrowHitboxHiddenKey: true,
            Player2ThrowableHitboxHiddenKey: true,
            Player2PushHitboxHiddenKey: true,
            PreferredPassiveHitboxRGBColorKey: 0x0000FF,
            PreferredOtherVulnerabilityHitboxRGBColorKey: 0x007FFF,
            PreferredActiveHitboxRGBColorKey: 0xFF0000,
            PreferredThrowHitboxRGBColorKey: 0xFF7F00,
            PreferredThrowableHitboxRGBColorKey: 0x00FF00,
            PreferredPushHitboxRGBColorKey: 0x7F00FF,
            PreferredFramesPerSecondKey: 30,
        ]
    }
}
