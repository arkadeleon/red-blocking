//
//  NavigationRootView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct NavigationRootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var navigation = appModel.navigation

        NavigationSplitView {
            CharacterListView(model: appModel.characterList)
        } detail: {
            NavigationStack(path: $navigation.detailPath) {
                detailContent
            }
            .navigationDestination(for: MoveDestination.self, destination: MoveDestinationView.init)
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        if let rootNode = appModel.navigation.currentRootNode {
            MoveNodeView(node: rootNode)
        } else if let errorMessage = appModel.characterList.errorMessage {
            ContentUnavailableView(
                "Characters Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else {
            ContentUnavailableView(
                "Select a Character",
                systemImage: "rectangle.split.2x1",
                description: Text("Choose a character in the sidebar to drive the SwiftUI detail stack.")
            )
        }
    }
}
