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

extension View {
    func redBlockingPanel(cornerRadius: CGFloat = 24, elevated: Bool = false) -> some View {
        modifier(RedBlockingPanelModifier(cornerRadius: cornerRadius, elevated: elevated))
    }

    func redBlockingInsetPanel(cornerRadius: CGFloat = 22) -> some View {
        modifier(RedBlockingInsetPanelModifier(cornerRadius: cornerRadius))
    }
}
