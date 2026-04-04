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
    @State private var isExpanded: Bool

    init(
        title: String,
        startsExpanded: Bool,
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
        _isExpanded = State(initialValue: startsExpanded)
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: toggleExpanded) {
                MotionPlayerHitboxVisibilityHeaderView(
                    title: title,
                    summaryText: summaryText,
                    isExpanded: isExpanded
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .redBlockingControlSurface(cornerRadius: 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(RedBlockingPressableButtonStyle())
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint(isExpanded ? "Collapses the hitbox group." : "Expands the hitbox group.")

            if isExpanded {
                MotionPlayerHitboxToggleStackView(
                    passiveColorRGB: passiveColorRGB,
                    passiveVisible: $passiveVisible,
                    otherVulnerabilityColorRGB: otherVulnerabilityColorRGB,
                    otherVulnerabilityVisible: $otherVulnerabilityVisible,
                    activeColorRGB: activeColorRGB,
                    activeVisible: $activeVisible,
                    throwColorRGB: throwColorRGB,
                    throwVisible: $throwVisible,
                    throwableColorRGB: throwableColorRGB,
                    throwableVisible: $throwableVisible,
                    pushColorRGB: pushColorRGB,
                    pushVisible: $pushVisible
                )
                .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))
            }
        }
    }

    private func toggleExpanded() {
        if reduceMotion {
            isExpanded.toggle()
        } else {
            withAnimation(.snappy(duration: 0.26, extraBounce: 0)) {
                isExpanded.toggle()
            }
        }
    }

    private var summaryText: String {
        let visibleCount = [
            passiveVisible,
            otherVulnerabilityVisible,
            activeVisible,
            throwVisible,
            throwableVisible,
            pushVisible
        ].filter { $0 }.count

        if visibleCount == 0 {
            return "All layers hidden"
        }

        return visibleCount == 1 ? "1 layer visible" : "\(visibleCount) layers visible"
    }
}
