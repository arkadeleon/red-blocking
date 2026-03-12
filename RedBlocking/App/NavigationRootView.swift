//
//  NavigationRootView.swift
//  RedBlocking
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
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 360)
        } detail: {
            NavigationStack(path: $navigation.detailPath) {
                NavigationDetailView()
            }
            .navigationDestination(for: MoveDestination.self) { destination in
                MoveDestinationView(destination: destination)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview("Navigation Root") {
    let appModel = PreviewAppModel.rootNavigation()

    return NavigationRootView()
        .environment(appModel)
}
