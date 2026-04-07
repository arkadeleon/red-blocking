//
//  MoveSupplementaryRowView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveSupplementaryRowView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .redBlockingText(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Move Supplementary Row") {
    MoveSupplementaryRowView(title: "Can be kara-canceled into throw.")
        .padding()
        .background(Color.rbCoal)
}
