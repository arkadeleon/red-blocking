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
                    .fill(Color.black.opacity(0.96))

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
                    .strokeBorder(Color.black.opacity(0.78), lineWidth: diameter * 0.035)
                    .padding(diameter * 0.06)

                if isSelected {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.96, blue: 0.68),
                                    Color(red: 1.00, green: 0.58, blue: 0.11)
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
            .shadow(
                color: Color.black.opacity(isSelected ? 0.46 : 0.28),
                radius: isSelected ? diameter * 0.10 : diameter * 0.05,
                x: 0,
                y: isSelected ? diameter * 0.05 : diameter * 0.03
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .offset(y: isSelected ? -diameter * 0.03 : 0)
            .animation(selectionAnimation, value: isSelected)
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel(character.title)
        .accessibilityHint("Browse \(character.title)'s moves.")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var selectionAnimation: Animation {
        if accessibilityReduceMotion {
            return .easeOut(duration: 0.12)
        }

        return .spring(duration: 0.28, bounce: 0.18)
    }
}
