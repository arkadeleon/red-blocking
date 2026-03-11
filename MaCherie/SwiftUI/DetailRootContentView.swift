//
//  DetailRootContentView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DetailRootContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        if let rootNode = appModel.navigation.currentRootNode {
            MoveNodeView(node: rootNode)
        } else if let errorMessage = appModel.characterList.errorMessage {
            VStack {
                ContentUnavailableView(
                    "Characters Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        } else {
            VStack {
                ContentUnavailableView(
                    "Select a Character",
                    systemImage: "rectangle.split.2x1",
                    description: Text("Choose a character in the sidebar to drive the SwiftUI detail stack.")
                )
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        }
    }
}
