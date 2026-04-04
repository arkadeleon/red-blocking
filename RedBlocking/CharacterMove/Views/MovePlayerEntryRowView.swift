//
//  MovePlayerEntryRowView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MovePlayerEntryRowView: View {
    let title: String
    let subtitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            rowContent
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 14, highlighted: true)
                .contentShape(Rectangle())
        }
        .buttonStyle(RedBlockingPressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the move preview.")
    }

    @ViewBuilder
    private var rowContent: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
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
            Image(systemName: "play.fill")
                .font(.caption.weight(.bold))

            Text("Preview")
                .font(.caption.weight(.bold))
        }
        .redBlockingText(.inverse)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.rbGold.opacity(0.96),
                            Color.rbAmber.opacity(0.94)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.rbGold.opacity(0.42), lineWidth: 1)
                }
        }
        .accessibilityHidden(true)
        .fixedSize(horizontal: true, vertical: false)
    }
}
