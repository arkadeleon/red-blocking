//
//  MotionPlayerHitboxVisibilityHeaderView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerHitboxVisibilityHeaderView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let summaryText: String
    let isExpanded: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(title)
                    .redBlockingSectionTag()

                Text(summaryText)
                    .font(.caption.weight(.medium))
                    .redBlockingText(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer(minLength: 12)

                chevron
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Text(title)
                        .redBlockingSectionTag()

                    Spacer(minLength: 12)

                    chevron
                }

                Text(summaryText)
                    .font(.caption.weight(.medium))
                    .redBlockingText(.secondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .font(.caption.weight(.bold))
            .redBlockingText(.accentSoft)
            .rotationEffect(.degrees(isExpanded ? -180 : 0))
    }
}
