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
