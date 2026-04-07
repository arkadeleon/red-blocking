//
//  MoveBrowserSectionRowsView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MoveBrowserSectionRowsView: View {
    let section: MoveBrowserSection
    let model: MoveBrowserModel
    let displayScale: CGFloat
    let rowSpacingResolver: (MoveBrowserRow) -> CGFloat
    let dividerInsetResolver: (MoveBrowserRow) -> CGFloat

    var body: some View {
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
    }
}

#Preview("Move Browser Section Rows") {
    let preview = PreviewAppModel.moveBrowserModel()
    let section = MoveBrowserSection(
        id: "preview-rows",
        title: "Preview",
        rows: [
            .motionPlayer(
                id: "dragon-punch",
                title: "Shoryuken",
                subtitle: "623P",
                characterCode: "RYU",
                skillCode: "DP"
            ),
            .detail(id: "startup", title: "Startup", value: "3"),
            .supplementary(id: "note", title: "Cancelable into Super Art on hit."),
            .next(id: "browse-more", title: "More Uppercuts", node: preview.node)
        ]
    )

    return MoveBrowserSectionRowsView(
        section: section,
        model: preview.model,
        displayScale: 3,
        rowSpacingResolver: { _ in 12 },
        dividerInsetResolver: { row in
            row.kind == .detail ? 24 : 16
        }
    )
    .padding(16)
    .redBlockingPanel(cornerRadius: 22)
    .padding()
    .background(Color.rbCoal)
}
