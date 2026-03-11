//
//  PlaybackSettings.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@Observable
final class PlaybackSettings {
    private enum Keys {
        static let framesPerSecond = "PreferredFramesPerSecond"
    }

    private let userDefaults: UserDefaults

    var framesPerSecond: Int {
        didSet {
            let clampedValue = Self.clamp(framesPerSecond)
            if framesPerSecond != clampedValue {
                framesPerSecond = clampedValue
                return
            }

            userDefaults.set(clampedValue, forKey: Keys.framesPerSecond)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        userDefaults.register(defaults: Self.defaultValues())

        framesPerSecond = Self.clamp(userDefaults.integer(forKey: Keys.framesPerSecond))
    }

    private static func clamp(_ value: Int) -> Int {
        min(max(value, 0), 60)
    }

    static func defaultValues() -> [String: Any] {
        [
            Keys.framesPerSecond: 30,
        ]
    }
}
