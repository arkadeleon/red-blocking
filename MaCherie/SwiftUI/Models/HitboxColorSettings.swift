//
//  HitboxColorSettings.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class HitboxColorSettings {
    private enum Keys {
        static let passiveRGB = "PreferredPassiveHitboxRGBColor"
        static let otherVulnerabilityRGB = "PreferredOtherVulnerabilityHitboxRGBColor"
        static let activeRGB = "PreferredActiveHitboxRGBColor"
        static let throwRGB = "PreferredThrowHitboxRGBColor"
        static let throwableRGB = "PreferredThrowableHitboxRGBColor"
        static let pushRGB = "PreferredPushHitboxRGBColor"
    }

    private let userDefaults: UserDefaults

    var passiveRGB: Int {
        didSet { userDefaults.set(passiveRGB, forKey: Keys.passiveRGB) }
    }

    var otherVulnerabilityRGB: Int {
        didSet { userDefaults.set(otherVulnerabilityRGB, forKey: Keys.otherVulnerabilityRGB) }
    }

    var activeRGB: Int {
        didSet { userDefaults.set(activeRGB, forKey: Keys.activeRGB) }
    }

    var throwRGB: Int {
        didSet { userDefaults.set(throwRGB, forKey: Keys.throwRGB) }
    }

    var throwableRGB: Int {
        didSet { userDefaults.set(throwableRGB, forKey: Keys.throwableRGB) }
    }

    var pushRGB: Int {
        didSet { userDefaults.set(pushRGB, forKey: Keys.pushRGB) }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        userDefaults.register(defaults: Self.defaultValues())

        passiveRGB = userDefaults.integer(forKey: Keys.passiveRGB)
        otherVulnerabilityRGB = userDefaults.integer(forKey: Keys.otherVulnerabilityRGB)
        activeRGB = userDefaults.integer(forKey: Keys.activeRGB)
        throwRGB = userDefaults.integer(forKey: Keys.throwRGB)
        throwableRGB = userDefaults.integer(forKey: Keys.throwableRGB)
        pushRGB = userDefaults.integer(forKey: Keys.pushRGB)
    }

    static func defaultValues() -> [String: Any] {
        [
            Keys.passiveRGB: 0x0000FF,
            Keys.otherVulnerabilityRGB: 0x007FFF,
            Keys.activeRGB: 0xFF0000,
            Keys.throwRGB: 0xFF7F00,
            Keys.throwableRGB: 0x00FF00,
            Keys.pushRGB: 0x7F00FF,
        ]
    }
}
