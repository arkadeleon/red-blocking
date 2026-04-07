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
        Group {
            if isCollapsedByDefault {
                MoveBrowserCollapsibleSectionPanel(
                    section: section,
                    model: model,
                    displayScale: displayScale,
                    rowSpacingResolver: verticalPadding(for:),
                    dividerInsetResolver: dividerLeadingInset(for:),
                    summary: sectionSummary
                )
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    if section.title?.isEmpty == false {
                        sectionHeader
                    }

                    MoveBrowserSectionRowsView(
                        section: section,
                        model: model,
                        displayScale: displayScale,
                        rowSpacingResolver: verticalPadding(for:),
                        dividerInsetResolver: dividerLeadingInset(for:)
                    )
                    .redBlockingPanel(cornerRadius: 22)
                }
            }
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

    @ViewBuilder
    private var sectionHeader: some View {
        if let title = section.title, !title.isEmpty {
            HStack(spacing: 10) {
                Text(title)
                    .redBlockingSectionTag(prominent: isProminent)

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
    }

    private var sectionSummary: String {
        let noteCount = section.rows.filter { $0.kind == .supplementary }.count
        if noteCount > 0 {
            return noteCount == 1 ? "1 note" : "\(noteCount) notes"
        }

        let valueCount = section.rows.filter { $0.kind == .detail }.count
        return valueCount == 1 ? "1 value" : "\(valueCount) values"
    }

    private var isCollapsedByDefault: Bool {
        hasMotionPlayerRow == false
            && hasNavigationRow == false
            && section.title?.isEmpty == false
    }

    private var isProminent: Bool {
        hasMotionPlayerRow
    }

    private var hasMotionPlayerRow: Bool {
        section.rows.contains { $0.kind == .motionPlayer }
    }

    private var hasNavigationRow: Bool {
        section.rows.contains { $0.kind == .next }
    }
}

#Preview("Section Panel") {
    let preview = PreviewAppModel.moveBrowserModel()
    let section = MoveBrowserSection(
        id: "specials",
        title: "Special Moves",
        rows: [
            .motionPlayer(
                id: "hadoken",
                title: "Hadoken",
                subtitle: "236P",
                characterCode: "RYU",
                skillCode: "HADOU"
            ),
            .detail(id: "startup", title: "Startup", value: "13"),
            .supplementary(id: "note", title: "Fastest version controls space well."),
            .next(id: "supers", title: "Super Arts", node: preview.node)
        ]
    )

    return ScrollView {
        MoveBrowserSectionPanel(section: section, model: preview.model)
            .padding(16)
    }
    .background(Color.rbCoal)
}
