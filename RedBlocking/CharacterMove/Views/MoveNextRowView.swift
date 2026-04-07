//
//  MoveNextRowView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveNextRowView: View {
    let title: String
    let subtitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            rowContent
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 14)
                .contentShape(Rectangle())
        }
        .buttonStyle(RedBlockingPressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens this move category.")
    }

    @ViewBuilder
    private var rowContent: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                titleStack
                Spacer(minLength: 12)
                rowBadge
            }

            VStack(alignment: .leading, spacing: 12) {
                titleStack

                HStack {
                    rowBadge
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var titleStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body.weight(.semibold))
                .redBlockingText(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .redBlockingText(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .layoutPriority(1)
    }

    private var rowBadge: some View {
        HStack(spacing: 6) {
            Text("Browse")
                .font(.caption.weight(.bold))

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
        }
        .redBlockingText(.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            Capsule(style: .continuous)
                .fill(Color.rbCoal.opacity(0.72))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.rbPanelBorder.opacity(0.48), lineWidth: 1)
                }
        }
        .accessibilityHidden(true)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Move Next Row") {
    MoveNextRowView(
        title: "Special Moves",
        subtitle: "Browse quarter-circle, charge, and command inputs.",
        action: {}
    )
    .padding()
    .background(Color.rbCoal)
}
