//
//  MoveBrowserSectionPanel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/19.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveBrowserSectionPanel: View {
    let section: MoveBrowserSection
    let model: MoveBrowserModel

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = section.title, !title.isEmpty {
                HStack(spacing: 10) {
                    Text(title)
                        .redBlockingSectionTag(prominent: true)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.rbGold.opacity(0.36),
                                    Color.rbScarlet.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: max(1 / displayScale, 1))
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                    if index > 0 {
                        Rectangle()
                            .fill(Color.rbPanelBorder.opacity(0.28))
                            .frame(height: 1 / displayScale)
                            .padding(.leading, dividerLeadingInset(for: row))
                    }

                    MoveBrowserRowView(row: row, model: model)
                        .padding(.horizontal, 16)
                        .padding(.vertical, verticalPadding(for: row))
                }
            }
            .redBlockingPanel(cornerRadius: 22)
        }
    }

    private func verticalPadding(for row: MoveBrowserRow) -> CGFloat {
        switch row.kind {
        case .motionPlayer:
            14
        case .next:
            12
        case .detail:
            8
        case .supplementary:
            10
        }
    }

    private func dividerLeadingInset(for row: MoveBrowserRow) -> CGFloat {
        switch row.kind {
        case .detail:
            24
        case .supplementary:
            20
        case .next, .motionPlayer:
            16
        }
    }
}
