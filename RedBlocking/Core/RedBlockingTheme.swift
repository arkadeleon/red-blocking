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
    static let rbTextMuted = Color("RBTextMuted")
}

enum RedBlockingTextRole {
    case primary
    case secondary
    case accent
    case accentSoft
    case inverse

    var color: Color {
        switch self {
        case .primary:
            Color.white.opacity(0.96)
        case .secondary:
            Color.rbTextMuted
        case .accent:
            Color.rbAmber.opacity(0.96)
        case .accentSoft:
            Color.rbAmber.opacity(0.90)
        case .inverse:
            Color.rbCoal
        }
    }
}

struct RedBlockingShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum RedBlockingShadowToken {
    static func panel(elevated: Bool) -> RedBlockingShadowStyle {
        RedBlockingShadowStyle(
            color: Color.black.opacity(elevated ? 0.40 : 0.28),
            radius: elevated ? 20 : 14,
            x: 0,
            y: elevated ? 12 : 8
        )
    }

    static func actionButton(prominent: Bool, isPressed: Bool, isEnabled: Bool) -> RedBlockingShadowStyle {
        RedBlockingShadowStyle(
            color: prominent ? Color.rbAmber.opacity(0.18) : Color.black.opacity(0.16),
            radius: isPressed ? 6 : (isEnabled ? 12 : 8),
            x: 0,
            y: isPressed ? 3 : (isEnabled ? 7 : 4)
        )
    }

    static func rosterSelection(isSelected: Bool, diameter: CGFloat) -> RedBlockingShadowStyle {
        RedBlockingShadowStyle(
            color: isSelected ? Color.rbScarlet.opacity(0.28) : Color.black.opacity(0.28),
            radius: isSelected ? diameter * 0.10 : diameter * 0.05,
            x: 0,
            y: isSelected ? diameter * 0.05 : diameter * 0.03
        )
    }

    static func icon(diameter: CGFloat) -> RedBlockingShadowStyle {
        RedBlockingShadowStyle(
            color: Color.black.opacity(0.35),
            radius: diameter * 0.03,
            x: 0,
            y: diameter * 0.02
        )
    }
}

enum RedBlockingOverlayToken {
    static func characterDetailScrim(isCompact: Bool) -> LinearGradient {
        LinearGradient(
            colors: isCompact
                ? [
                    Color.rbPanel.opacity(0.98),
                    Color.rbPanelElevated.opacity(0.86),
                    Color.rbCoal.opacity(0.58)
                ]
                : [
                    Color.rbPanel.opacity(0.92),
                    Color.rbPanelElevated.opacity(0.60),
                    Color.rbCoal.opacity(0.18)
                ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var rosterHeatScrim: LinearGradient {
        LinearGradient(
            colors: [
                Color.rbScarlet.opacity(0.0),
                Color.rbBurgundy.opacity(0.32)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var rosterDepthScrim: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                Color.black.opacity(0.18),
                Color.rbCoal.opacity(0.50)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var rosterHighlightVeil: LinearGradient {
        LinearGradient(
            colors: [
                Color.rbAmber.opacity(0.14),
                Color.black.opacity(0.05),
                Color.black.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
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
                    .redBlockingShadow(RedBlockingShadowToken.panel(elevated: elevated))
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
            .foregroundStyle(prominent ? Color.rbGold : Color.rbTextMuted)
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    let prominent: Bool

    init(prominent: Bool = false) {
        self.prominent = prominent
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .redBlockingText(prominent ? .inverse : .accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .opacity(isEnabled ? 1 : 0.62)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundFill(isPressed: configuration.isPressed))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(borderStyle, lineWidth: 1)
                    }
                    .redBlockingShadow(
                        RedBlockingShadowToken.actionButton(
                            prominent: prominent,
                            isPressed: configuration.isPressed,
                            isEnabled: isEnabled
                        )
                    )
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: configuration.isPressed)
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

struct RedBlockingPressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    let pressedScale: CGFloat
    let pressedOpacity: Double

    init(pressedScale: CGFloat = 0.985, pressedOpacity: Double = 0.96) {
        self.pressedScale = pressedScale
        self.pressedOpacity = pressedOpacity
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? (configuration.isPressed ? pressedOpacity : 1) : 0.62)
            .scaleEffect(configuration.isPressed && isEnabled ? pressedScale : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

extension View {
    func redBlockingText(_ role: RedBlockingTextRole) -> some View {
        foregroundStyle(role.color)
    }

    func redBlockingShadow(_ style: RedBlockingShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

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
