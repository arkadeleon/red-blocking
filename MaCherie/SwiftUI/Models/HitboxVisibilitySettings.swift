//
//  HitboxVisibilitySettings.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class HitboxVisibilitySettings {
    private enum Keys {
        static let player1PassiveHidden = "Player1PassiveHitboxHidden"
        static let player1OtherVulnerabilityHidden = "Player1OtherVulnerabilityHitboxHidden"
        static let player1ActiveHidden = "Player1ActiveHitboxHidden"
        static let player1ThrowHidden = "Player1ThrowHitboxHidden"
        static let player1ThrowableHidden = "Player1ThrowableHitboxHidden"
        static let player1PushHidden = "Player1PushHitboxHidden"

        static let player2PassiveHidden = "Player2PassiveHitboxHidden"
        static let player2OtherVulnerabilityHidden = "Player2OtherVulnerabilityHitboxHidden"
        static let player2ActiveHidden = "Player2ActiveHitboxHidden"
        static let player2ThrowHidden = "Player2ThrowHitboxHidden"
        static let player2ThrowableHidden = "Player2ThrowableHitboxHidden"
        static let player2PushHidden = "Player2PushHitboxHidden"
    }

    private let userDefaults: UserDefaults

    var player1PassiveVisible: Bool {
        didSet { persistVisibility(player1PassiveVisible, hiddenKey: Keys.player1PassiveHidden) }
    }

    var player1OtherVulnerabilityVisible: Bool {
        didSet { persistVisibility(player1OtherVulnerabilityVisible, hiddenKey: Keys.player1OtherVulnerabilityHidden) }
    }

    var player1ActiveVisible: Bool {
        didSet { persistVisibility(player1ActiveVisible, hiddenKey: Keys.player1ActiveHidden) }
    }

    var player1ThrowVisible: Bool {
        didSet { persistVisibility(player1ThrowVisible, hiddenKey: Keys.player1ThrowHidden) }
    }

    var player1ThrowableVisible: Bool {
        didSet { persistVisibility(player1ThrowableVisible, hiddenKey: Keys.player1ThrowableHidden) }
    }

    var player1PushVisible: Bool {
        didSet { persistVisibility(player1PushVisible, hiddenKey: Keys.player1PushHidden) }
    }

    var player2PassiveVisible: Bool {
        didSet { persistVisibility(player2PassiveVisible, hiddenKey: Keys.player2PassiveHidden) }
    }

    var player2OtherVulnerabilityVisible: Bool {
        didSet { persistVisibility(player2OtherVulnerabilityVisible, hiddenKey: Keys.player2OtherVulnerabilityHidden) }
    }

    var player2ActiveVisible: Bool {
        didSet { persistVisibility(player2ActiveVisible, hiddenKey: Keys.player2ActiveHidden) }
    }

    var player2ThrowVisible: Bool {
        didSet { persistVisibility(player2ThrowVisible, hiddenKey: Keys.player2ThrowHidden) }
    }

    var player2ThrowableVisible: Bool {
        didSet { persistVisibility(player2ThrowableVisible, hiddenKey: Keys.player2ThrowableHidden) }
    }

    var player2PushVisible: Bool {
        didSet { persistVisibility(player2PushVisible, hiddenKey: Keys.player2PushHidden) }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        userDefaults.register(defaults: Self.defaultValues())

        player1PassiveVisible = !userDefaults.bool(forKey: Keys.player1PassiveHidden)
        player1OtherVulnerabilityVisible = !userDefaults.bool(forKey: Keys.player1OtherVulnerabilityHidden)
        player1ActiveVisible = !userDefaults.bool(forKey: Keys.player1ActiveHidden)
        player1ThrowVisible = !userDefaults.bool(forKey: Keys.player1ThrowHidden)
        player1ThrowableVisible = !userDefaults.bool(forKey: Keys.player1ThrowableHidden)
        player1PushVisible = !userDefaults.bool(forKey: Keys.player1PushHidden)

        player2PassiveVisible = !userDefaults.bool(forKey: Keys.player2PassiveHidden)
        player2OtherVulnerabilityVisible = !userDefaults.bool(forKey: Keys.player2OtherVulnerabilityHidden)
        player2ActiveVisible = !userDefaults.bool(forKey: Keys.player2ActiveHidden)
        player2ThrowVisible = !userDefaults.bool(forKey: Keys.player2ThrowHidden)
        player2ThrowableVisible = !userDefaults.bool(forKey: Keys.player2ThrowableHidden)
        player2PushVisible = !userDefaults.bool(forKey: Keys.player2PushHidden)
    }

    private func persistVisibility(_ isVisible: Bool, hiddenKey: String) {
        userDefaults.set(!isVisible, forKey: hiddenKey)
    }

    static func defaultValues() -> [String: Any] {
        [
            Keys.player1PassiveHidden: false,
            Keys.player1OtherVulnerabilityHidden: false,
            Keys.player1ActiveHidden: false,
            Keys.player1ThrowHidden: false,
            Keys.player1ThrowableHidden: false,
            Keys.player1PushHidden: false,
            Keys.player2PassiveHidden: true,
            Keys.player2OtherVulnerabilityHidden: true,
            Keys.player2ActiveHidden: true,
            Keys.player2ThrowHidden: true,
            Keys.player2ThrowableHidden: true,
            Keys.player2PushHidden: true,
        ]
    }
}
