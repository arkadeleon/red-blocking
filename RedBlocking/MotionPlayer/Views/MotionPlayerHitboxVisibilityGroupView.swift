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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 12) {
                    Text(title)
                        .redBlockingSectionTag()

                    Text(summaryText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 12)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.rbAmber.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .redBlockingControlSurface(cornerRadius: 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
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
        }
        .padding(16)
        .redBlockingControlSurface(cornerRadius: 22)
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

        return visibleCount == 1 ? "1 layer visible" : "\(visibleCount) layers visible"
    }
}
