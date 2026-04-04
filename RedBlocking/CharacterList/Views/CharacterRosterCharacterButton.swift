//
//  CharacterRosterCharacterButton.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterRosterCharacterButton: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    let character: CharacterSelection
    let isSelected: Bool
    let diameter: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.rbCoal)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.18 : 0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(character.rowAssetName)
                    .resizable()
                    .interpolation(.none)
                    .antialiased(false)
                    .scaledToFill()
                    .frame(width: diameter * 0.88, height: diameter * 0.88)
                    .clipShape(Circle())
                    .brightness(isSelected ? 0.06 : 0.0)
                    .saturation(isSelected ? 1.08 : 1.0)
                    .accessibilityHidden(true)

                Circle()
                    .strokeBorder(Color.rbPanelBorder.opacity(0.58), lineWidth: diameter * 0.035)
                    .padding(diameter * 0.06)

                if isSelected {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.rbGold,
                                    Color.rbAmber
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: diameter * 0.065
                        )
                        .padding(diameter * 0.01)

                    if differentiateWithoutColor {
                        VStack {
                            Capsule()
                                .fill(Color.white.opacity(0.96))
                                .frame(width: diameter * 0.28, height: diameter * 0.055)
                            Spacer()
                            Capsule()
                                .fill(Color.white.opacity(0.96))
                                .frame(width: diameter * 0.28, height: diameter * 0.055)
                        }
                        .padding(diameter * 0.08)

                        HStack {
                            Capsule()
                                .fill(Color.white.opacity(0.96))
                                .frame(width: diameter * 0.055, height: diameter * 0.28)
                            Spacer()
                            Capsule()
                                .fill(Color.white.opacity(0.96))
                                .frame(width: diameter * 0.055, height: diameter * 0.28)
                        }
                        .padding(diameter * 0.08)
                    }
                }
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .redBlockingShadow(RedBlockingShadowToken.rosterSelection(isSelected: isSelected, diameter: diameter))
            .scaleEffect(accessibilityReduceMotion ? 1.0 : (isSelected ? 1.08 : 1.0))
            .offset(y: accessibilityReduceMotion ? 0 : (isSelected ? -diameter * 0.03 : 0))
            .animation(selectionAnimation, value: isSelected)
        }
        .buttonStyle(RedBlockingPressableButtonStyle(pressedScale: 0.97, pressedOpacity: 0.94))
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel(character.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(
            isSelected
                ? "\(character.title) is already selected."
                : "Browse \(character.title)'s moves."
        )
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var selectionAnimation: Animation? {
        accessibilityReduceMotion ? nil : .easeOut(duration: 0.22)
    }
}
