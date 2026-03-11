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
                DetailRootContentView()
            }
            .navigationDestination(for: MoveDestination.self, destination: MoveDestinationView.init)
        }
    }
}
