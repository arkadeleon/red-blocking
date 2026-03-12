//
//  MotionCanvasConfiguration.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

struct MotionCanvasConfiguration {
    let player1PassiveVisible: Bool
    let player1OtherVulnerabilityVisible: Bool
    let player1ActiveVisible: Bool
    let player1ThrowVisible: Bool
    let player1ThrowableVisible: Bool
    let player1PushVisible: Bool

    let player2PassiveVisible: Bool
    let player2OtherVulnerabilityVisible: Bool
    let player2ActiveVisible: Bool
    let player2ThrowVisible: Bool
    let player2ThrowableVisible: Bool
    let player2PushVisible: Bool

    let passiveRGB: Int
    let otherVulnerabilityRGB: Int
    let activeRGB: Int
    let throwRGB: Int
    let throwableRGB: Int
    let pushRGB: Int

    @MainActor
    init(
        hitboxVisibilitySettings: HitboxVisibilitySettings,
        hitboxColorSettings: HitboxColorSettings
    ) {
        player1PassiveVisible = hitboxVisibilitySettings.player1PassiveVisible
        player1OtherVulnerabilityVisible = hitboxVisibilitySettings.player1OtherVulnerabilityVisible
        player1ActiveVisible = hitboxVisibilitySettings.player1ActiveVisible
        player1ThrowVisible = hitboxVisibilitySettings.player1ThrowVisible
        player1ThrowableVisible = hitboxVisibilitySettings.player1ThrowableVisible
        player1PushVisible = hitboxVisibilitySettings.player1PushVisible

        player2PassiveVisible = hitboxVisibilitySettings.player2PassiveVisible
        player2OtherVulnerabilityVisible = hitboxVisibilitySettings.player2OtherVulnerabilityVisible
        player2ActiveVisible = hitboxVisibilitySettings.player2ActiveVisible
        player2ThrowVisible = hitboxVisibilitySettings.player2ThrowVisible
        player2ThrowableVisible = hitboxVisibilitySettings.player2ThrowableVisible
        player2PushVisible = hitboxVisibilitySettings.player2PushVisible

        passiveRGB = hitboxColorSettings.passiveRGB
        otherVulnerabilityRGB = hitboxColorSettings.otherVulnerabilityRGB
        activeRGB = hitboxColorSettings.activeRGB
        throwRGB = hitboxColorSettings.throwRGB
        throwableRGB = hitboxColorSettings.throwableRGB
        pushRGB = hitboxColorSettings.pushRGB
    }
}
