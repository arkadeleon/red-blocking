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
            if sectionBehavior.isCollapsedByDefault {
                CollapsibleSectionPanel(
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

                    sectionRows
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
                    .redBlockingSectionTag(prominent: sectionBehavior.isProminent)

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

    private var sectionRows: some View {
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
    }

    private var sectionBehavior: SectionBehavior {
        let hasMotionPlayerRow = section.rows.contains { $0.kind == .motionPlayer }
        let hasNavigationRow = section.rows.contains { $0.kind == .next }

        return SectionBehavior(
            isCollapsedByDefault: hasMotionPlayerRow == false
                && hasNavigationRow == false
                && section.title?.isEmpty == false,
            isProminent: hasMotionPlayerRow
        )
    }

    private var sectionSummary: String {
        let noteCount = section.rows.filter { $0.kind == .supplementary }.count
        if noteCount > 0 {
            return noteCount == 1 ? "1 note" : "\(noteCount) notes"
        }

        let valueCount = section.rows.filter { $0.kind == .detail }.count
        return valueCount == 1 ? "1 value" : "\(valueCount) values"
    }
}

private extension MoveBrowserSectionPanel {
    struct SectionBehavior {
        let isCollapsedByDefault: Bool
        let isProminent: Bool
    }
}

private struct CollapsibleSectionPanel: View {
    let section: MoveBrowserSection
    let model: MoveBrowserModel
    let displayScale: CGFloat
    let rowSpacingResolver: (MoveBrowserRow) -> CGFloat
    let dividerInsetResolver: (MoveBrowserRow) -> CGFloat
    let summary: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { toggleExpanded() }) {
                HStack(spacing: 12) {
                    if let title = section.title, !title.isEmpty {
                        Text(title)
                            .redBlockingSectionTag()
                    }

                    Text(summary)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 12)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.rbAmber.opacity(0.9))
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(isExpanded ? "Collapses this section." : "Expands this section.")

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.rbPanelBorder.opacity(0.28))
                                .frame(height: 1 / displayScale)
                                .padding(.leading, dividerInsetResolver(row))
                        }

                        MoveBrowserRowView(row: row, model: model)
                            .padding(.horizontal, 16)
                            .padding(.vertical, rowSpacingResolver(row))
                    }
                }
                .redBlockingPanel(cornerRadius: 22)
                .transition(.opacity)
            }
        }
    }

    private func toggleExpanded() {
        if reduceMotion {
            isExpanded.toggle()
        } else {
            withAnimation(.snappy(duration: 0.28)) {
                isExpanded.toggle()
            }
        }
    }
}
