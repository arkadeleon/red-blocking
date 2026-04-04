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
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.rbTextMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 12)

                rowBadge
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .redBlockingControlSurface(cornerRadius: 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(RedBlockingPressableButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens this move category.")
    }

    private var rowBadge: some View {
        HStack(spacing: 6) {
            Text("Browse")
                .font(.caption.weight(.bold))

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(Color.rbAmber.opacity(0.94))
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
    }
}
