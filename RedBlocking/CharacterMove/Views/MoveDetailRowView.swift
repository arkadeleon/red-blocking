//
//  MoveDetailRowView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveDetailRowView: View {
    let title: String
    let detail: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                titleText
                Spacer(minLength: 8)
                detailText(multilineAlignment: .trailing)
            }

            VStack(alignment: .leading, spacing: 4) {
                titleText
                detailText(multilineAlignment: .leading)
            }
        }
    }

    private var titleText: some View {
        Text(title)
            .font(.caption.weight(.bold))
            .kerning(0.4)
            .redBlockingText(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func detailText(multilineAlignment: TextAlignment) -> some View {
        Text(detail)
            .font(.body.weight(.medium))
            .redBlockingText(.primary)
            .multilineTextAlignment(multilineAlignment)
            .fixedSize(horizontal: false, vertical: true)
    }
}
