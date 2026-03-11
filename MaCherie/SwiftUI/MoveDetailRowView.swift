//
//  MoveDetailRowView.swift
//  MaCherie
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
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func detailText(multilineAlignment: TextAlignment) -> some View {
        Text(detail)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(multilineAlignment)
            .fixedSize(horizontal: false, vertical: true)
    }
}
