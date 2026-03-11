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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: CharacterListModel

    var body: some View {
        @Bindable var model = model

        Group {
            if horizontalSizeClass == .regular {
                listContent(selection: $model.selectedCharacter)
                    .listStyle(.sidebar)
            } else {
                listContent(selection: $model.selectedCharacter)
                    .listStyle(.insetGrouped)
            }
        }
        .scrollContentBackground(.hidden)
        .background(listBackground)
        .navigationTitle("Characters")
        .onChange(of: horizontalSizeClass, initial: true) { _, newValue in
            model.applyDefaultSelectionIfNeeded(for: newValue)
        }
        .onChange(of: model.characters, initial: true) { _, _ in
            model.applyDefaultSelectionIfNeeded(for: horizontalSizeClass)
        }
    }

    private func listContent(selection: Binding<CharacterSelection?>) -> some View {
        List(selection: selection) {
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
                        .accessibilityLabel(character.title)
                    }
                }
            }
        }
    }

    private func row(for character: CharacterSelection) -> some View {
        HStack(spacing: 12) {
            Image(character.rowAssetName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: dynamicTypeSize.isAccessibilitySize ? 52 : 44,
                    height: dynamicTypeSize.isAccessibilitySize ? 52 : 44
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(character.title)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 8 : 4)
        .contentShape(Rectangle())
    }

    private var listBackground: some View {
        Color(uiColor: horizontalSizeClass == .regular ? .secondarySystemGroupedBackground : .systemGroupedBackground)
            .ignoresSafeArea()
    }
}
