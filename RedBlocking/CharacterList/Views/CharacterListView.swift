//
//  CharacterListView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let model: CharacterListModel
    let onActivateSelection: (CharacterSelection) -> Void

    var body: some View {
        @Bindable var model = model

        GeometryReader { proxy in
            ZStack {
                CharacterRosterBackgroundView()

                if let errorMessage = model.errorMessage {
                    VStack {
                        ContentUnavailableView(
                            "Couldn't Load Characters",
                            systemImage: "exclamationmark.triangle",
                            description: Text(errorMessage)
                        )
                        .padding(24)
                        .redBlockingPanel()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                } else if model.characters.isEmpty {
                    VStack {
                        ContentUnavailableView(
                            "No Characters Yet",
                            systemImage: "person.slash",
                            description: Text("Characters will appear here once the data is available.")
                        )
                        .padding(24)
                        .redBlockingPanel()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        CharacterRosterBoardView(
                            characters: model.characters,
                            selectedCharacter: model.selectedCharacter,
                            containerWidth: proxy.size.width,
                            minimumHeight: proxy.size.height,
                            activateCharacter: { selection in
                                model.selectedCharacter = selection
                                onActivateSelection(selection)
                            }
                        )
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
        }
        .navigationTitle("Character Select")
        .toolbarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onChange(of: horizontalSizeClass, initial: true) { _, newValue in
            model.applyDefaultSelectionIfNeeded(for: newValue)
        }
        .onChange(of: model.characters, initial: true) { _, _ in
            model.applyDefaultSelectionIfNeeded(for: horizontalSizeClass)
        }
    }
}
