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
        VStack(alignment: .leading, spacing: 8) {
            if let title = section.title, !title.isEmpty {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 4)
            }

            VStack(spacing: 0) {
                ForEach(Array(section.rows.enumerated()), id: \.element.id) { index, row in
                    if index > 0 {
                        Rectangle()
                            .fill(Color.rbPanelBorder.opacity(0.28))
                            .frame(height: 1 / displayScale)
                            .padding(.leading, 16)
                    }

                    MoveBrowserRowView(row: row, model: model)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                }
            }
            .redBlockingPanel(cornerRadius: 16)
        }
    }
}
