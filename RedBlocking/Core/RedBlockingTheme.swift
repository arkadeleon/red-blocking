//
//  RedBlockingTheme.swift
//  RedBlocking
//
//  Created by Codex on 2026/3/13.
//

import SwiftUI

extension Color {
    static let rbAmber = Color("RBAmber")
    static let rbBurgundy = Color("RBBurgundy")
    static let rbCanvas = Color("RBCanvas")
    static let rbCobalt = Color("RBCobalt")
    static let rbCoal = Color("RBCoal")
    static let rbEmber = Color("RBEmber")
    static let rbGold = Color("RBGold")
    static let rbPanel = Color("RBPanel")
    static let rbPanelBorder = Color("RBPanelBorder")
    static let rbPanelElevated = Color("RBPanelElevated")
    static let rbScarlet = Color("RBScarlet")
}

private struct RedBlockingPanelModifier: ViewModifier {
    let cornerRadius: CGFloat
    let elevated: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(elevated ? Color.rbPanelElevated : Color.rbPanel)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.rbGold.opacity(0.30),
                                        Color.rbPanelBorder.opacity(0.72),
                                        Color.rbScarlet.opacity(0.24)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: Color.black.opacity(elevated ? 0.40 : 0.28),
                        radius: elevated ? 20 : 14,
                        x: 0,
                        y: elevated ? 12 : 8
                    )
            }
    }
}

private struct RedBlockingInsetPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.rbCoal.opacity(0.88))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.rbPanelBorder.opacity(0.45), lineWidth: 1)
                    }
            }
    }
}

private struct RedBlockingControlSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let highlighted: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        highlighted
                            ? LinearGradient(
                                colors: [
                                    Color.rbAmber.opacity(0.16),
                                    Color.rbPanelElevated.opacity(0.92),
                                    Color.rbCoal.opacity(0.96)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.rbCoal.opacity(0.72),
                                    Color.rbPanel.opacity(0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                highlighted
                                    ? LinearGradient(
                                        colors: [
                                            Color.rbGold.opacity(0.44),
                                            Color.rbAmber.opacity(0.38),
                                            Color.rbScarlet.opacity(0.18)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [
                                            Color.rbPanelBorder.opacity(0.58),
                                            Color.rbScarlet.opacity(0.14)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                    }
            }
    }
}

private struct RedBlockingSectionTagModifier: ViewModifier {
    let prominent: Bool

    func body(content: Content) -> some View {
        content
            .font(prominent ? .caption.weight(.black) : .caption.weight(.bold))
            .kerning(prominent ? 1.2 : 0.9)
            .textCase(.uppercase)
            .foregroundStyle(prominent ? Color.rbGold : Color.rbAmber.opacity(0.92))
            .padding(.horizontal, prominent ? 12 : 10)
            .padding(.vertical, prominent ? 7 : 6)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        prominent
                            ? LinearGradient(
                                colors: [
                                    Color.rbScarlet.opacity(0.30),
                                    Color.rbBurgundy.opacity(0.66),
                                    Color.rbCoal.opacity(0.92)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.rbCoal.opacity(0.82),
                                    Color.rbPanel.opacity(0.92)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(
                                prominent ? Color.rbGold.opacity(0.42) : Color.rbPanelBorder.opacity(0.46),
                                lineWidth: 1
                            )
                    }
            }
    }
}

struct RedBlockingActionButtonStyle: ButtonStyle {
    let prominent: Bool

    init(prominent: Bool = false) {
        self.prominent = prominent
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(prominent ? Color.rbCoal : Color.rbAmber.opacity(0.96))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundFill(isPressed: configuration.isPressed))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(borderStyle, lineWidth: 1)
                    }
                    .shadow(
                        color: prominent ? Color.rbAmber.opacity(0.18) : Color.black.opacity(0.16),
                        radius: configuration.isPressed ? 6 : 12,
                        x: 0,
                        y: configuration.isPressed ? 3 : 7
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }

    private func backgroundFill(isPressed: Bool) -> LinearGradient {
        if prominent {
            return LinearGradient(
                colors: [
                    Color.rbGold.opacity(isPressed ? 0.90 : 0.98),
                    Color.rbAmber.opacity(isPressed ? 0.88 : 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [
                Color.rbPanelElevated.opacity(isPressed ? 0.92 : 1.0),
                Color.rbPanel.opacity(isPressed ? 0.96 : 1.0),
                Color.rbCoal.opacity(isPressed ? 0.94 : 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderStyle: LinearGradient {
        if prominent {
            return LinearGradient(
                colors: [
                    Color.rbGold.opacity(0.62),
                    Color.rbAmber.opacity(0.36),
                    Color.rbScarlet.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [
                Color.rbAmber.opacity(0.26),
                Color.rbPanelBorder.opacity(0.72),
                Color.rbScarlet.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func redBlockingPanel(cornerRadius: CGFloat = 24, elevated: Bool = false) -> some View {
        modifier(RedBlockingPanelModifier(cornerRadius: cornerRadius, elevated: elevated))
    }

    func redBlockingInsetPanel(cornerRadius: CGFloat = 22) -> some View {
        modifier(RedBlockingInsetPanelModifier(cornerRadius: cornerRadius))
    }

    func redBlockingControlSurface(cornerRadius: CGFloat = 16, highlighted: Bool = false) -> some View {
        modifier(RedBlockingControlSurfaceModifier(cornerRadius: cornerRadius, highlighted: highlighted))
    }

    func redBlockingSectionTag(prominent: Bool = false) -> some View {
        modifier(RedBlockingSectionTagModifier(prominent: prominent))
    }
}
