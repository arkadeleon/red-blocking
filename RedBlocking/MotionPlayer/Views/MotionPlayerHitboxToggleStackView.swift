//
//  MotionPlayerHitboxToggleStackView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerHitboxToggleStackView: View {
    let passiveColorRGB: Int
    let otherVulnerabilityColorRGB: Int
    let activeColorRGB: Int
    let throwColorRGB: Int
    let throwableColorRGB: Int
    let pushColorRGB: Int

    @Binding private var passiveVisible: Bool
    @Binding private var otherVulnerabilityVisible: Bool
    @Binding private var activeVisible: Bool
    @Binding private var throwVisible: Bool
    @Binding private var throwableVisible: Bool
    @Binding private var pushVisible: Bool

    init(
        passiveColorRGB: Int,
        passiveVisible: Binding<Bool>,
        otherVulnerabilityColorRGB: Int,
        otherVulnerabilityVisible: Binding<Bool>,
        activeColorRGB: Int,
        activeVisible: Binding<Bool>,
        throwColorRGB: Int,
        throwVisible: Binding<Bool>,
        throwableColorRGB: Int,
        throwableVisible: Binding<Bool>,
        pushColorRGB: Int,
        pushVisible: Binding<Bool>
    ) {
        self.passiveColorRGB = passiveColorRGB
        self.otherVulnerabilityColorRGB = otherVulnerabilityColorRGB
        self.activeColorRGB = activeColorRGB
        self.throwColorRGB = throwColorRGB
        self.throwableColorRGB = throwableColorRGB
        self.pushColorRGB = pushColorRGB
        _passiveVisible = passiveVisible
        _otherVulnerabilityVisible = otherVulnerabilityVisible
        _activeVisible = activeVisible
        _throwVisible = throwVisible
        _throwableVisible = throwableVisible
        _pushVisible = pushVisible
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            MotionPlayerHitboxToggleView(
                title: "Passive",
                description: "Hurtbox present during neutral and non-attacking frames",
                symbolName: "shield",
                tintColor: Color(rgb: passiveColorRGB),
                isOn: $passiveVisible
            )
            MotionPlayerHitboxToggleView(
                title: "Vulnerability",
                description: "Extra hurtbox exposed during specific attack frames",
                symbolName: "shield.lefthalf.filled",
                tintColor: Color(rgb: otherVulnerabilityColorRGB),
                isOn: $otherVulnerabilityVisible
            )
            MotionPlayerHitboxToggleView(
                title: "Active",
                description: "Attack hitbox that deals damage on contact",
                symbolName: "burst.fill",
                tintColor: Color(rgb: activeColorRGB),
                isOn: $activeVisible
            )
            MotionPlayerHitboxToggleView(
                title: "Throw",
                description: "Area that initiates a throw when it reaches the opponent",
                symbolName: "hand.raised.fill",
                tintColor: Color(rgb: throwColorRGB),
                isOn: $throwVisible
            )
            MotionPlayerHitboxToggleView(
                title: "Throwable",
                description: "Area where the character can be grabbed",
                symbolName: "figure.fall",
                tintColor: Color(rgb: throwableColorRGB),
                isOn: $throwableVisible
            )
            MotionPlayerHitboxToggleView(
                title: "Push",
                description: "Collision box that prevents characters from overlapping",
                symbolName: "arrow.left.and.right.circle.fill",
                tintColor: Color(rgb: pushColorRGB),
                isOn: $pushVisible
            )
        }
    }
}

#Preview("Hitbox Toggle Stack") {
    @Previewable @State var passiveVisible = true
    @Previewable @State var otherVulnerabilityVisible = true
    @Previewable @State var activeVisible = true
    @Previewable @State var throwVisible = false
    @Previewable @State var throwableVisible = true
    @Previewable @State var pushVisible = true

    return MotionPlayerHitboxToggleStackView(
        passiveColorRGB: 0x00AEEF,
        passiveVisible: $passiveVisible,
        otherVulnerabilityColorRGB: 0x93D500,
        otherVulnerabilityVisible: $otherVulnerabilityVisible,
        activeColorRGB: 0xFF3B30,
        activeVisible: $activeVisible,
        throwColorRGB: 0xFF9500,
        throwVisible: $throwVisible,
        throwableColorRGB: 0xAF52DE,
        throwableVisible: $throwableVisible,
        pushColorRGB: 0xFFD60A,
        pushVisible: $pushVisible
    )
    .padding()
    .background(Color.rbCoal)
}
