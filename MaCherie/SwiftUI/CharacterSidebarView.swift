//
//  CharacterSidebarView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterSidebarView: View {
    @Binding var selectedCharacter: CharacterSelection?

    let characters: [CharacterSelection]
    let errorMessage: String?

    var body: some View {
        List(selection: $selectedCharacter) {
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                }
            }

            if characters.isEmpty, errorMessage == nil {
                ContentUnavailableView(
                    "No Characters",
                    systemImage: "person.slash",
                    description: Text("The sidebar will populate once character data is available.")
                )
            } else {
                Section("Characters") {
                    ForEach(characters) { character in
                        NavigationLink(value: character) {
                            Text(character.title)
                        }
                    }
                }
            }
        }
        .navigationTitle("Characters")
    }
}
