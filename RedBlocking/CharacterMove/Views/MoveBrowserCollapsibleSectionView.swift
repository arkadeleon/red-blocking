//
//  MoveBrowserCollapsibleSectionView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MoveBrowserCollapsibleSectionView: View {
    let section: MoveBrowserSection
    let model: MoveBrowserModel
    let displayScale: CGFloat
    let rowSpacingResolver: (MoveBrowserRow) -> CGFloat
    let dividerInsetResolver: (MoveBrowserRow) -> CGFloat
    let summary: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggleExpanded) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        titleLabel

                        Text(summary)
                            .font(.caption.weight(.medium))
                            .redBlockingText(.secondary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)

                        Spacer(minLength: 12)

                        chevron
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            titleLabel
                            Spacer(minLength: 12)
                            chevron
                        }

                        Text(summary)
                            .font(.caption.weight(.medium))
                            .redBlockingText(.secondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(RedBlockingPressableButtonStyle())
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            .accessibilityHint(isExpanded ? "Collapses this section." : "Expands this section.")

            if isExpanded {
                MoveBrowserSectionRowsView(
                    section: section,
                    model: model,
                    displayScale: displayScale,
                    rowSpacingResolver: rowSpacingResolver,
                    dividerInsetResolver: dividerInsetResolver
                )
                .redBlockingPanel(cornerRadius: 22)
                .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))
            }
        }
    }

    @ViewBuilder
    private var titleLabel: some View {
        if let title = section.title, !title.isEmpty {
            Text(title)
                .redBlockingSectionTag()
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .font(.caption.weight(.bold))
            .redBlockingText(.accentSoft)
            .rotationEffect(.degrees(isExpanded ? -180 : 0))
    }

    private func toggleExpanded() {
        if reduceMotion {
            isExpanded.toggle()
        } else {
            withAnimation(.snappy(duration: 0.26, extraBounce: 0)) {
                isExpanded.toggle()
            }
        }
    }
}

#Preview("Move Browser Collapsible Section") {
    let preview = PreviewAppModel.moveBrowserModel()
    let section = MoveBrowserSection(
        id: "frame-data",
        title: "Frame Data",
        rows: [
            .detail(id: "startup", title: "Startup", value: "5"),
            .detail(id: "recovery", title: "Recovery", value: "18"),
            .supplementary(id: "note", title: "Safe against most lights at max range.")
        ]
    )

    return ScrollView {
        MoveBrowserCollapsibleSectionView(
            section: section,
            model: preview.model,
            displayScale: 3,
            rowSpacingResolver: { _ in 10 },
            dividerInsetResolver: { row in
                row.kind == .detail ? 24 : 20
            },
            summary: "2 values, 1 note"
        )
        .padding(16)
    }
    .background(Color.rbCoal)
}
