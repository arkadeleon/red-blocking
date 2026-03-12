//
//  MotionPlayerHitboxVisibilityGroupView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerHitboxVisibilityGroupView: View {
    let title: String
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
        title: String,
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
        self.title = title
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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            LazyVStack(alignment: .leading, spacing: 12) {
                MotionPlayerHitboxToggleView(
                    title: "Passive",
                    symbolName: "shield",
                    tintColor: Color(rgb: passiveColorRGB),
                    isOn: $passiveVisible
                )
                MotionPlayerHitboxToggleView(
                    title: "Vulnerability",
                    symbolName: "shield.lefthalf.filled",
                    tintColor: Color(rgb: otherVulnerabilityColorRGB),
                    isOn: $otherVulnerabilityVisible
                )
                MotionPlayerHitboxToggleView(
                    title: "Active",
                    symbolName: "burst.fill",
                    tintColor: Color(rgb: activeColorRGB),
                    isOn: $activeVisible
                )
                MotionPlayerHitboxToggleView(
                    title: "Throw",
                    symbolName: "hand.raised.fill",
                    tintColor: Color(rgb: throwColorRGB),
                    isOn: $throwVisible
                )
                MotionPlayerHitboxToggleView(
                    title: "Throwable",
                    symbolName: "figure.fall",
                    tintColor: Color(rgb: throwableColorRGB),
                    isOn: $throwableVisible
                )
                MotionPlayerHitboxToggleView(
                    title: "Push",
                    symbolName: "arrow.left.and.right.circle.fill",
                    tintColor: Color(rgb: pushColorRGB),
                    isOn: $pushVisible
                )
            }
        }
        .padding(16)
        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
