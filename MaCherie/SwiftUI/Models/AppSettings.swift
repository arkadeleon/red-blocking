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
    static let standard = AppSettings()

    let userDefaults: UserDefaults

    let hitboxVisibility: HitboxVisibilitySettings
    let hitboxColors: HitboxColorSettings
    let playback: PlaybackSettings

    init(
        userDefaults: UserDefaults = .standard,
        hitboxVisibility: HitboxVisibilitySettings? = nil,
        hitboxColors: HitboxColorSettings? = nil,
        playback: PlaybackSettings? = nil
    ) {
        self.userDefaults = userDefaults
        userDefaults.register(defaults: Self.defaultValues())

        self.hitboxVisibility = hitboxVisibility ?? HitboxVisibilitySettings(userDefaults: userDefaults)
        self.hitboxColors = hitboxColors ?? HitboxColorSettings(userDefaults: userDefaults)
        self.playback = playback ?? PlaybackSettings(userDefaults: userDefaults)
    }

    private static func defaultValues() -> [String: Any] {
        HitboxVisibilitySettings.defaultValues()
            .merging(HitboxColorSettings.defaultValues()) { _, newValue in newValue }
            .merging(PlaybackSettings.defaultValues()) { _, newValue in newValue }
    }
}
