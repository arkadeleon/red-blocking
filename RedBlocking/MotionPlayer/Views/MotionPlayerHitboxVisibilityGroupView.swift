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
    let startsExpanded: Bool
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
        self.startsExpanded = startsExpanded
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
            Button(action: { toggleExpanded() }) {
                HStack(spacing: 12) {
                    Text(title)
                        .redBlockingSectionTag()

                    Text(summaryText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.rbAmber.opacity(0.74))
                        .lineLimit(1)

                    Spacer(minLength: 12)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.rbAmber.opacity(0.9))
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .redBlockingControlSurface(cornerRadius: 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(RedBlockingPressableButtonStyle())
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint(isExpanded ? "Collapses the hitbox group." : "Expands the hitbox group.")

            if isExpanded {
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
