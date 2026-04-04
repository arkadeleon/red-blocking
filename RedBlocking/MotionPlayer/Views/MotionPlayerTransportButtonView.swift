//
//  MotionPlayerTransportButtonView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerTransportButtonView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let systemImage: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let prominent: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        if reduceMotion {
            button
        } else {
            button
                .contentTransition(.symbolEffect(.replace.offUp))
        }
    }

    private var button: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: prominent ? 24 : 18, weight: .black, design: .rounded))
                .redBlockingText(prominent ? .inverse : .accent)
                .frame(maxWidth: .infinity)
                .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 60 : 48)
                .background {
                    if prominent {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.rbGold.opacity(0.98),
                                        Color.rbAmber.opacity(0.96)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Capsule(style: .continuous)
                                    .strokeBorder(Color.rbGold.opacity(0.44), lineWidth: 1)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                    }
                }
                .contentShape(Rectangle())
        }
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .buttonStyle(RedBlockingPressableButtonStyle(pressedScale: 0.96, pressedOpacity: 0.92))
    }
}
