//
//  NavigationDetailView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct NavigationDetailView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        if let rootNode = appModel.navigation.currentRootNode {
            MoveBrowserPageView(node: rootNode)
        } else {
            ZStack {
                CharacterDetailBackgroundView(selection: appModel.navigation.selectedCharacter)

                if let errorMessage = appModel.navigation.currentProfileErrorMessage {
                    unavailableState(
                        title: "Couldn't Load Moves",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if let errorMessage = appModel.characterList.errorMessage {
                    unavailableState(
                        title: "Couldn't Load Characters",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    unavailableState(
                        title: "Select a Character",
                        systemImage: "rectangle.split.2x1",
                        description: Text("Choose a character to browse their moves.")
                    )
                }
            }
        }
    }

    private func unavailableState(title: String, systemImage: String, description: Text) -> some View {
        VStack {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: description
            )
            .padding(24)
            .redBlockingPanel()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
