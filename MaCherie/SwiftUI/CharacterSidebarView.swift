//
//  CharacterSidebarView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let model: CharacterListModel

    var body: some View {
        @Bindable var model = model

        List(selection: $model.selectedCharacter) {
            if let errorMessage = model.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                }
            }

            if model.characters.isEmpty, model.errorMessage == nil {
                ContentUnavailableView(
                    "No Characters",
                    systemImage: "person.slash",
                    description: Text("The sidebar will populate once character data is available.")
                )
            } else {
                Section("Characters") {
                    ForEach(model.characters) { character in
                        NavigationLink(value: character) {
                            row(for: character)
                        }
                    }
                }
            }
        }
        .navigationTitle("Characters")
        .onChange(of: horizontalSizeClass, initial: true) { _, newValue in
            model.applyDefaultSelectionIfNeeded(for: newValue)
        }
        .onChange(of: model.characters, initial: true) { _, _ in
            model.applyDefaultSelectionIfNeeded(for: horizontalSizeClass)
        }
    }

    private func row(for character: CharacterSelection) -> some View {
        HStack(spacing: 12) {
            Image(character.rowAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityHidden(true)

            Text(character.title)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}
